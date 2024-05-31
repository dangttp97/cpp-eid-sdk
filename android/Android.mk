LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := mylibrary
LOCAL_SRC_FILES := ../../src/mylibrary.cpp
LOCAL_C_INCLUDES := $(LOCAL_PATH)/../../include \
                    $(LOCAL_PATH)/../../third_parties/openssl/android/include \
                    $(LOCAL_PATH)/../../third_parties/curl/android/include

LOCAL_LDLIBS := -L$(LOCAL_PATH)/../../third_parties/openssl/android/lib \
                -L$(LOCAL_PATH)/../../third_parties/curl/android/lib \
                -lssl -lcrypto -lcurl

include $(BUILD_SHARED_LIBRARY)
