#!/bin/bash

# set -e

# Variables
OPENSSL_BUILD_DIR="../build/openssl"
CURL_BUILD_DIR="../build/curl"
IOS_SDK_VERSION="12.0"
PLATFORMS=("iphoneos")

# Build OpenSSL for Android
build_openssl_android() {
    export ANDROID_NDK_ROOT="$ANDROID_HOME/ndk/27.0.11718014"
    ANDROID_ARCH="android-arm64"
    TARGET=aarch64-linux-android
    API=21
    TOOLCHAIN=$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/darwin-x86_64
    SYSROOT=$TOOLCHAIN/sysroot
    export PATH=$TOOLCHAIN/bin:$PATH
    export AR=$TOOLCHAIN/bin/llvm-ar
    export AS=$TOOLCHAIN/bin/llvm-as
    export CC="$TOOLCHAIN/bin/$TARGET$API-clang --sysroot=$SYSROOT"
    export CXX="$TOOLCHAIN/bin/$TARGET$API-clang++ --sysroot=$SYSROOT"
    export LD=$TOOLCHAIN/bin/ld
    export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
    export STRIP=$TOOLCHAIN/bin/llvm-strip

    cd "./openssl"

    ./Configure $ANDROID_ARCH --prefix="$PWD/$OPENSSL_BUILD_DIR/android" --sysroot=$SYSROOT -D__ANDROID_API__=$API
    make clean
    make -j$(sysctl -n hw.ncpu)
    make install_sw

    cd ..
}
# Build OpenSSL for iOS
build_openssl_ios() {
    cd "./openssl"

    for PLATFORM in "${PLATFORMS[@]}"; do
        case $PLATFORM in
            macosx)
                TARGET="darwin64-x86_64-cc"
                ARCH_FLAGS="-arch x86_64"
                ;;
            iphoneos)
                TARGET="ios64-cross"
                ARCH_FLAGS="-arch arm64"
                SDK_PATH=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk
                ;;
            iphonesimulator)
                TARGET="iossimulator-xcrun"
                ARCH_FLAGS="-arch x86_64 -arch arm64"
                ;;
        esac

        export CXX=`xcrun --sdk $PLATFORM --find clang++`
        export CXXFLAGS="-fno-common -isysroot $SDK_PATH $ARCH_FLAGS"
        export LFLAGS="-L$(OPENSSL_BUILD_DIR)/lib -static"
        export CC=$(xcrun --sdk $PLATFORM --find clang)" -isysroot $SDK_PATH"
        export CFLAGS="-O3 -D_REENTRANT -fno-common -isysroot $SDK_PATH"
        export LDFLAGS="-Wl,--verbose"

        ./Configure $TARGET no-shared --prefix="$PWD/$OPENSSL_BUILD_DIR/$PLATFORM"
        make clean
        make -j$(sysctl -n hw.ncpu)
        make install_sw
    done
    
    cd ..
}

# Build cURL for Android
build_curl_android() {
    cd ./curl

    export ANDROID_NDK_ROOT="$ANDROID_HOME/ndk/27.0.11718014"
    TARGET=aarch64-linux-android
    API=21
    TOOLCHAIN=$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/darwin-x86_64
    SYSROOT=$TOOLCHAIN/sysroot
    export PATH=$TOOLCHAIN/bin:$PATH
    export AR=$TOOLCHAIN/bin/llvm-ar
    export AS=$TOOLCHAIN/bin/llvm-as
    export CC="$TOOLCHAIN/bin/$TARGET$API-clang --sysroot=$SYSROOT"
    export CXX="$TOOLCHAIN/bin/$TARGET$API-clang++ --sysroot=$SYSROOT"
    export LD=$TOOLCHAIN/bin/ld
    export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
    export STRIP=$TOOLCHAIN/bin/llvm-strip
    export CPPFLAGS="-I$PWD/$OPENSSL_BUILD_DIR/android/include"
    export LDFLAGS="-L$PWD/$OPENSSL_BUILD_DIR/android/lib"

    ./configure --host=$TARGET --prefix="$PWD/$CURL_BUILD_DIR/android" --with-openssl
    make clean
    make -j$(sysctl -n hw.ncpu)
    make install

    cd ..
}
# Build cURL for iOS
build_curl_ios() {
    cd "./curl"

    for PLATFORM in "${PLATFORMS[@]}"; do
        case $PLATFORM in
            macosx)
                ARCH_FLAGS="-arch x86_64"
                HOST_TRIPLET="x86_64-apple-darwin"
                ;;
            iphoneos)
                ARCH_FLAGS="-arch arm64"
                HOST_TRIPLET="arm-apple-darwin"
                ;;
            iphonesimulator)
                ARCH_FLAGS="-arch x86_64 -arch arm64"
                HOST_TRIPLET="x86_64-apple-darwin"
                ;;
        esac

        SDK=$(xcrun --sdk $PLATFORM --show-sdk-path)

        if [ -z "$SDK" ]; then
            echo "Error: SDK for $PLATFORM cannot be located."
            exit 1
        fi

        CC=$(xcrun --sdk $PLATFORM --find clang)
        CXX=$(xcrun --sdk $PLATFORM --find clang++)
        AR=$(xcrun --sdk $PLATFORM --find ar)
        AS=$(xcrun --sdk $PLATFORM --find as)
        RANLIB=$(xcrun --sdk $PLATFORM --find ranlib)
        STRIP=$(xcrun --sdk $PLATFORM --find strip)

        export CC="$CC $ARCH_FLAGS -isysroot $SDK"
        export CXX="$CXX $ARCH_FLAGS -isysroot $SDK"
        export AR
        export AS
        export RANLIB
        export STRIP
        export CFLAGS="-isysroot $SDK $ARCH_FLAGS"
        export CXXFLAGS="-isysroot $SDK $ARCH_FLAGS"
        export LDFLAGS="-isysroot $SDK $ARCH_FLAGS -L$PWD/../openssl/$PLATFORM/lib"
        export CPPFLAGS="-I$PWD/../openssl/$PLATFORM/include"

        if [ "$PLATFORM" == "macosx" ]; then
            OPENSSL_LIB="$PWD/../openssl/$PLATFORM/lib/libcrypto.dylib $PWD/../openssl/$PLATFORM/lib/libssl.dylib"
        else
            OPENSSL_LIB="$PWD/../openssl/$PLATFORM/lib/libcrypto.a $PWD/../openssl/$PLATFORM/lib/libssl.a"
        fi

        ./configure --host=$HOST_TRIPLET --prefix="$PWD/../build/$PLATFORM" --with-ssl=$PWD/../openssl/$PLATFORM --with-libssl-prefix=$PWD/../openssl/$PLATFORM --with-ca-path=/etc/ssl/certs --with-ca-bundle=/etc/ssl/certs/ca-certificates.crt --enable-threaded-resolver
        make clean
        make -j$(sysctl -n hw.ncpu)
        make install

        cd ..
    done

    cd ..
}

# Main execution
# build_openssl_android
build_openssl_ios
# build_curl_android
# build_curl_ios

echo "Dependencies build completed for Android and iOS."