#import <Preferences/Preferences.h>

#define kUrl_MakeDonation @"https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=BW2BNFCK5TQ3N"
#define PLIST_PATH @"/var/mobile/Library/Preferences/com.lablabla.muteicon.plist"
static NSMutableDictionary *preferences;

@interface MuteIconPrefsListController: PSListController {
}
@end

@implementation MuteIconPrefsListController
- (id)initForContentSize:(CGSize)size
{
	if ((self = [super initForContentSize:size]) != nil)
	{
		preferences = [[NSMutableDictionary dictionaryWithContentsOfFile:PLIST_PATH] retain] ?: [NSMutableDictionary dictionary];
	}

	return self;
}

-(id)specifiers
{
	if (_specifiers == nil)
	{
		_specifiers = [[self loadSpecifiersFromPlistName:@"MuteIconPrefs" target:self] retain];
	}
	return _specifiers;
}

-(void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier
{
	NSString *key = specifier.properties[@"key"];
	// preferences = ([NSMutableDictionary dictionaryWithContentsOfFile:PLIST_PATH] ?: [NSMutableDictionary dictionary]);
	[preferences setObject:value forKey:key];
	[preferences writeToFile:PLIST_PATH atomically:YES];

	NSString *post = specifier.properties[@"PostNotification"];
	if (post)
	{
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)post, NULL, NULL, TRUE);
	}
}

-(id)readPreferenceValue:(PSSpecifier *)specifier
{
	NSString *key = [specifier propertyForKey:@"key"];
	id defaultValue = [specifier propertyForKey:@"default"];
	id plistValue = [preferences objectForKey:key];
	if (!plistValue) plistValue = defaultValue;

	return plistValue;
}

-(void)makeDonation:(PSSpecifier *)specifier
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:kUrl_MakeDonation]];
}
@end
