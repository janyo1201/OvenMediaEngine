LOCAL_PATH := $(call get_local_path)
include $(DEFAULT_VARIABLES)

LOCAL_TARGET := webrtc

LOCAL_CFLAGS := $(shell pkg-config --cflags srt)
LOCAL_CXXFLAGS := $(shell pkg-config --cflags srt)

include $(BUILD_STATIC_LIBRARY)