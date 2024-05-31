#!/bin/bash

set -e

# Variables
BUILD_DIR="build"
ANDROID_NDK_ROOT="$ANDROID_HOME/ndk/27.0.11718014"
API=21

build_dependencies(){
    SCRIPT_DIR="./third_parties"
    cd $SCRIPT_DIR
    
    for script in ./*.sh; 
    do
    # Check if the file exists and is executable
    if [ -f "$script" ] && [ -x "$script" ]; then
        echo "Running $script..."
        # Run the script
        "$script"
        echo "$script finished."
    else
        echo "$script is not executable or does not exist."
    fi
    done
}

# Function to build for Android
build_android() {
    mkdir -p $BUILD_DIR/android
    cd $BUILD_DIR/android

    cmake -DANDROID=1 \
          -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK_ROOT/build/cmake/android.toolchain.cmake \
          -DANDROID_ABI=arm64-v8a \
          -DANDROID_PLATFORM=android-$API \
          -DOPENSSL_ROOT_DIR=$PWD/../../third_parties/build/openssl/android \
          -DCURL_ROOT_DIR=$PWD/../../third_parties/build/curl/android \
          -DCMAKE_BUILD_TYPE=Release \
          ../..

    make -j$(nproc)
    cd ../..
}

# Function to build for iOS
build_ios() {
    mkdir -p $BUILD_DIR/ios
    cd $BUILD_DIR/ios

    cmake -DIOS=1 \
          -DCMAKE_TOOLCHAIN_FILE=./ios.toolchain.cmake \
          -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_SYSTEM_NAME=iOS \
          -DCMAKE_OSX_SYSROOT=iphoneos \
          -DCMAKE_OSX_ARCHITECTURES=arm64 \
          -DOPENSSL_ROOT_DIR=$PWD/../../third_parties/build/openssl/iphoneos \
          -DCURL_ROOT_DIR=$PWD/../../third_parties/build/curl/iphoneos \
          ../..

    make -j$(sysctl -n hw.ncpu)
    cd ../..
}

# Main script
case "$1" in
    build_deps)
        build_dependencies
        ;;
    android)
        build_android
        ;;
    ios)
        build_ios
        ;;
    *)
        echo "Usage: $0 {android|ios|build_deps}"
        exit 1
        ;;
esac

echo "Build completed for $1."