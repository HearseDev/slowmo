TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = MobileSlideShow
include $(THEOS)/makefiles/common.mk
TWEAK_NAME = SlowMo
SlowMo_FILES = Tweak.x
SlowMo_CFLAGS = -fobjc-arc
include $(THEOS_MAKE_PATH)/tweak.mk
