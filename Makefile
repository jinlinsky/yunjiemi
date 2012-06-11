include /var/theos/makefiles/common.mk

APPLICATION_NAME = YunJieMi
YunJieMi_FILES = main.m YunJieMiApplication.mm RootViewController.mm Socket.mm File.mm
YunJieMi_FRAMEWORKS = MediaPlayer UIKit

include /var/theos/makefiles/application.mk
