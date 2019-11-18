LOCAL_PATH := $(call get_local_path)
include $(DEFAULT_VARIABLES)

LOCAL_TARGET := dtls_srtp

LOCAL_CFLAGS := $(shell pkg-config --cflags openssl) $(shell pkg-config --cflags srt)
LOCAL_CXXFLAGS := $(shell pkg-config --cflags openssl) $(shell pkg-config --cflags srt)
LOCAL_LDFLAGS := $(shell pkg-config --libs openssl)

include $(BUILD_STATIC_LIBRARY)
