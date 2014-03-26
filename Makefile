ARCHS = armv7 arm64
include theos/makefiles/common.mk

LIBRARY_NAME = SRShortener
SRShortener_FILES = SRShortener.m
SRShortener_INSTALL_PATH = /Library/ActionMenu/Plugins
SRShortener_FRAMEWORKS = Foundation UIKit CoreGraphics

include $(THEOS_MAKE_PATH)/library.mk
