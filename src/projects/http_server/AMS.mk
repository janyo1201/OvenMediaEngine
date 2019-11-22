LOCAL_PATH := $(call get_local_path)
include $(DEFAULT_VARIABLES)

LOCAL_TARGET := http_server

LOCAL_SOURCE_FILES := $(LOCAL_SOURCE_FILES) \
    $(call get_sub_source_list,interceptors) \
    $(call get_sub_source_list,interceptors/**)

LOCAL_HEADER_FILES := $(LOCAL_HEADER_FILES) \
    $(call get_sub_header_list,interceptors) \
    $(call get_sub_header_list,interceptors/**)

LOCAL_CFLAGS := $(shell pkg-config --cflags openssl)
LOCAL_CXXFLAGS := $(shell pkg-config --cflags openssl)

include $(BUILD_STATIC_LIBRARY)
