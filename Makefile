TARGET := iphone:clang

TWEAK_NAME = MuteIcon
MuteIcon_FILES = Tweak.xm Settings.mm

PACKAGE_VERSION = $(THEOS_PACKAGE_BASE_VERSION)

# export THEOS_PLATFORM_SDK_ROOT_armv6 = /Volumes/Xcode/Xcode.app/Contents/Developer
export SDKVERSION_armv7 = 7.0
export SDKVERSION_arm64 = 7.0
export TARGET_IPHONEOS_DEPLOYMENT_VERSION_armv7 = 6.0
export TARGET_IPHONEOS_DEPLOYMENT_VERSION_arm64 = 7.0
export ARCHS = armv7 arm64
include $(THEOS)/makefiles/common.mk

MuteIcon_FRAMEWORKS = UIKit
MuteIcon_CFLAGS = -Iinclude

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += muteiconprefs

include $(THEOS_MAKE_PATH)/aggregate.mk

internal-after-install::
	install.exec "killall -9 SpringBoard"
