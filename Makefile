include theos/makefiles/common.mk

APPLICATION_NAME = YunJieMi
YunJieMi_FILES = main.m YunJieMiApplication.mm RootViewController.mm Socket.mm

include $(THEOS_MAKE_PATH)/application.mk
