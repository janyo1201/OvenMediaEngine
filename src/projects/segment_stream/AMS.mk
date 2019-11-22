LOCAL_PATH := $(call get_local_path)
include $(DEFAULT_VARIABLES)

LOCAL_TARGET := segment_stream

LOCAL_SOURCE_FILES := $(LOCAL_SOURCE_FILES) $(call get_sub_source_list,packetyzer)
LOCAL_HEADER_FILES := $(LOCAL_HEADER_FILES) $(call get_sub_source_list,packetyzer)

LOCAL_CFLAGS := $(shell pkg-config --cflags srt)
LOCAL_CXXFLAGS := $(shell pkg-config --cflags srt)

include $(BUILD_STATIC_LIBRARY)