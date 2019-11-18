LOCAL_PATH := $(call get_local_path)
include $(DEFAULT_VARIABLES)

LOCAL_TARGET := ovlibrary

LOCAL_HEADER_FILES := $(LOCAL_HEADER_FILES)
LOCAL_SOURCE_FILES := $(LOCAL_SOURCE_FILES)

LOCAL_CFLAGS := $(shell pkg-config --cflags openssl)
LOCAL_CXXFLAGS := $(shell pkg-config --cflags openssl)

include $(BUILD_STATIC_LIBRARY)
