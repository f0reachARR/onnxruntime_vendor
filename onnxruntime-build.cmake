include(ExternalProject)

option(ONNXRUNTIME_LATEST "Use the latest ONNX Runtime version" ON)

if(ONNXRUNTIME_LATEST STREQUAL "ON")
    set(ONNXRUNTIME_TAG "main")
else()
    set(ONNXRUNTIME_TAG "v${ONNXRUNTIME_VERSION}")
endif()

if(NOT DEFINED ONNXRUNTIME_EXTRA_OPTS)
    set(ONNXRUNTIME_EXTRA_OPTS "")
endif()

string(REPLACE " " ";" ONNXRUNTIME_EXTRA_OPTS "${ONNXRUNTIME_EXTRA_OPTS}")

if(NOT DEFINED ONNXRUNTIME_BUILD_TYPE)
    set(ONNXRUNTIME_BUILD_TYPE "Release")
endif()

set(ONNXRUNTIME_BUILD_OPTIONS
    "--config" "${ONNXRUNTIME_BUILD_TYPE}"
    "--build_shared_lib"
    "--compile_no_warning_as_error"
    "--skip_pip_install"
    "--skip_tests"
    ${ONNXRUNTIME_EXTRA_OPTS}
)

option(ONNXRUNTIME_USE_CUDA "Build ONNX Runtime with CUDA support" OFF)
option(ONNXRUNTIME_USE_TENSORRT "Build ONNX Runtime with TensorRT support" OFF)
option(ONNXRUNTIME_USE_ROCM "Build ONNX Runtime with ROCm support" OFF)
option(ONNXRUNTIME_USE_RKNPU "Build ONNX Runtime with RK NPU support" OFF)

if(ONNXRUNTIME_USE_CUDA STREQUAL "ON")
    list(APPEND ONNXRUNTIME_BUILD_OPTIONS "--use_cuda")
endif()

if(ONNXRUNTIME_USE_TENSORRT STREQUAL "ON")
    list(APPEND ONNXRUNTIME_BUILD_OPTIONS "--use_tensorrt")
endif()

if(ONNXRUNTIME_USE_ROCM STREQUAL "ON")
    list(APPEND ONNXRUNTIME_BUILD_OPTIONS "--use_rocm")
endif()

if(ONNXRUNTIME_USE_RKNPU STREQUAL "ON")
    list(APPEND ONNXRUNTIME_BUILD_OPTIONS "--use_rknpu")
endif()

ExternalProject_Add(
    onnxruntime_external
    GIT_REPOSITORY https://github.com/microsoft/onnxruntime.git
    GIT_TAG ${ONNXRUNTIME_TAG}
    GIT_SUBMODULES_RECURSE TRUE
    GIT_SHALLOW TRUE
    CONFIGURE_COMMAND <SOURCE_DIR>/build.sh ${ONNXRUNTIME_BUILD_OPTIONS} --update
    BUILD_COMMAND <SOURCE_DIR>/build.sh ${ONNXRUNTIME_BUILD_OPTIONS} --build
    INSTALL_COMMAND cmake --install "<BINARY_DIR>/${ONNXRUNTIME_BUILD_TYPE}" --prefix <INSTALL_DIR>
)
