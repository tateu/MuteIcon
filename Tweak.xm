#import "SpringBoard/SBMediaController.h"
#import "LibStatusBar/LSStatusBarItem.h"
#import "Settings.h"

#define BELL_ICON @"ON_Mute_Bell"
#define SPEAKER_ICON @"ON_Mute_Speaker"
#define BELL_ICON_7 @"ON_Mute_7_Bell"
#define SPEAKER_ICON_7 @"ON_Mute_7_Speaker"

#ifndef kCFCoreFoundationVersionNumber_iOS_7_0
#define kCFCoreFoundationVersionNumber_iOS_7_0 847.2
#endif

LSStatusBarItem *icon;
BOOL enabled, bell;
Settings *settings;

void changeIcon()
{
	if (%c(SBMediaController) && [%c(SBMediaController) instancesRespondToSelector:@selector(isRingerMuted)])
	{
		bool isMute = [[%c(SBMediaController) sharedInstance] isRingerMuted];
		if (!isMute)
		{
			if (icon) {
				icon.visible = NO;
				[icon release];
				icon = nil;
			}
		}
		else
		{
			if (!icon) {
				icon = [[%c(LSStatusBarItem) alloc] initWithIdentifier:[NSString stringWithFormat:@"com.lablabla.muteicon"] alignment:StatusBarAlignmentRight];
			}

			if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_7_0) {
				[icon setImageName:bell ? BELL_ICON_7 : SPEAKER_ICON_7];
			}
			else
			{
				[icon setImageName:bell ? BELL_ICON : SPEAKER_ICON];
			}
			icon.visible = YES;
		}
	}
}

%hook SpringBoard
-(void)applicationDidFinishLaunching:(id)application
{
	%orig;

	settings = [[Settings alloc] init];
	[settings reloadPreferences];
	enabled = [[settings.preferences valueForKey:@"muteEnabled"] boolValue];
	bell = [[settings.preferences valueForKey:@"iconType"] boolValue];

	if (enabled)
	{
		changeIcon();
	}
}
%end

%hook SBMediaController
-(void)setRingerMuted:(BOOL)muted
{
	%orig;
	if (enabled)
	{
		changeIcon();
	}
}
%end

static void reloadPrefsNotification(CFNotificationCenterRef center,
									void *observer,
									CFStringRef name,
									const void *object,
									CFDictionaryRef userInfo)
{
	[settings reloadPreferences];
	enabled = [[settings.preferences valueForKey:@"muteEnabled"] boolValue];
	if (icon && (!enabled || bell != [[settings.preferences valueForKey:@"iconType"] boolValue])) {
		icon.visible = NO;
		[icon release];
		icon = nil;
	}

	bell = [[settings.preferences valueForKey:@"iconType"] boolValue];
	if (enabled)
	{
		changeIcon();
	}
}

%ctor
{
	//Register for the preferences-did-change notification
	CFNotificationCenterRef r = CFNotificationCenterGetDarwinNotifyCenter();
	CFNotificationCenterAddObserver(r, NULL, &reloadPrefsNotification, CFSTR("com.lablabla.muteicon/reloadPrefs"), NULL, 0);
}
