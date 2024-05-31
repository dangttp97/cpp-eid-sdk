cmake_minimum_required(VERSION 3.10)

project(EIDSDK)

# Add the library
file(GLOB_RECURSE EID_SDK_SRC "src/**/*.cpp")
file(GLOB_RECURSE EID_SDK_HEADERS "include/cpp_eid_sdk/*.h")
add_library(eid_sdk SHARED ${EID_SDK_SRC} ${EID_SDK_HEADERS})  # Use SHARED to create a .so file
target_include_directories(eid_sdk PUBLIC ${PROJECT_SOURCE_DIR}/include)

# Set platform-specific paths for OpenSSL and cURL
if (ANDROID)
    set(OPENSSL_ROOT_DIR ${CMAKE_CURRENT_SOURCE_DIR}/third_parties/build/openssl/android)
    set(CURL_ROOT_DIR ${CMAKE_CURRENT_SOURCE_DIR}/third_parties/build/curl/android)
    set(OPENSSL_INCLUDE_DIR ${OPENSSL_ROOT_DIR}/include)
    set(OPENSSL_CRYPTO_LIBRARY ${OPENSSL_ROOT_DIR}/lib/libcrypto.a)
    set(OPENSSL_SSL_LIBRARY ${OPENSSL_ROOT_DIR}/lib/libssl.a)
    set(CURL_INCLUDE_DIR ${CURL_ROOT_DIR}/include)
    set(CURL_LIBRARY ${CURL_ROOT_DIR}/lib/libcurl.a)
elseif (IOS)
    set(OPENSSL_ROOT_DIR ${CMAKE_CURRENT_SOURCE_DIR}/third_parties/build/openssl/iphoneos)
    set(CURL_ROOT_DIR ${CMAKE_CURRENT_SOURCE_DIR}/third_parties/build/curl_universal)  # Use universal path
    set(OPENSSL_INCLUDE_DIR ${OPENSSL_ROOT_DIR}/include)
    set(OPENSSL_CRYPTO_LIBRARY ${OPENSSL_ROOT_DIR}/lib/libcrypto.a)
    set(OPENSSL_SSL_LIBRARY ${OPENSSL_ROOT_DIR}/lib/libssl.a)
    set(CURL_INCLUDE_DIR ${CURL_ROOT_DIR}/include)
    set(CURL_LIBRARY ${CURL_ROOT_DIR}/lib/libcurl.a)
endif()

# Include directories for OpenSSL and cURL
include_directories(${OPENSSL_INCLUDE_DIR})
include_directories(${CURL_INCLUDE_DIR})
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include)

# Link the libraries to the target
target_link_libraries(eid_sdk ${OPENSSL_SSL_LIBRARY} ${OPENSSL_CRYPTO_LIBRARY} ${CURL_LIBRARY})


# Install the headers
install(DIRECTORY include/cpp_eid_sdk 
        DESTINATION include/ 
        FILES_MATCHING PATTERN "*.h")