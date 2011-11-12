include theos/makefiles/common.mk

TWEAK_NAME = SearchWordHighlighter
SearchWordHighlighter_FILES = Tweak.xm
SearchWordHighlighter_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk
