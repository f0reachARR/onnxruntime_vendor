include(FetchContent)

set(ONNXRUNTIME_BINARY_URL "https://github.com/microsoft/onnxruntime/releases/download/v${ONNXRUNTIME_VERSION}/onnxruntime-linux-x64-gpu-${ONNXRUNTIME_VERSION}.tgz")
FetchContent_Declare(onnxruntime_external
    URL ${ONNXRUNTIME_BINARY_URL}
    DOWNLOAD_EXTRACT_TIMESTAMP TRUE
)

FetchContent_Populate(onnxruntime_external)

install(DIRECTORY "${onnxruntime_external_SOURCE_DIR}/include/"
    DESTINATION include/
)

install(DIRECTORY "${onnxruntime_external_SOURCE_DIR}/lib/"
    DESTINATION lib/
    FILES_MATCHING PATTERN "*.so*" PATTERN "*.dylib*" PATTERN "*.dll*"
)

ament_package(CONFIG_EXTRAS "onnxruntime-extras.cmake.in")
