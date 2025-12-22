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

if(DEFINED ENV{ONNXRUNTIME_EXTRA_OPTS})
    set(ONNXRUNTIME_EXTRA_OPTS "$ENV{ONNXRUNTIME_EXTRA_OPTS} ${ONNXRUNTIME_EXTRA_OPTS}")
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
    "--allow_running_as_root"
    "--cmake_extra_defines"
    "onnxruntime_BUILD_UNIT_TESTS=OFF"
    ${ONNXRUNTIME_EXTRA_OPTS}
)

# If /usr/local/cuda exists, enable CUDA by default
if(EXISTS "/usr/local/cuda")
    list(APPEND ONNXRUNTIME_BUILD_OPTIONS "--use_cuda"
        "--cuda_home" "/usr/local/cuda"
        "--cudnn_home" "/usr/local/cuda")
endif()

# If "NvInfer.h" can be included, enable TensorRT by default
find_path(TENSORRT_INCLUDE_DIR NvInfer.h HINTS /usr/include /usr/local/include)

message(STATUS "TensorRT include dir: ${TENSORRT_INCLUDE_DIR}")

if(TENSORRT_INCLUDE_DIR)
    list(APPEND ONNXRUNTIME_BUILD_OPTIONS "--use_tensorrt" "--tensorrt_home" "/usr")
endif()

# If /opt/rocm/lib/migraphx exists, enable MIGraphX by default
if(EXISTS "/opt/rocm")
    list(APPEND ONNXRUNTIME_BUILD_OPTIONS "--use_migraphx" "--migraphx_home" "/opt/rocm")
endif()

message(STATUS "ONNX Runtime build options: ${ONNXRUNTIME_BUILD_OPTIONS}")

ExternalProject_Add(
    onnxruntime_external
    GIT_REPOSITORY https://github.com/microsoft/onnxruntime.git
    GIT_TAG ${ONNXRUNTIME_TAG}
    GIT_SUBMODULES_RECURSE TRUE
    GIT_SHALLOW TRUE
    CONFIGURE_COMMAND <SOURCE_DIR>/build.sh ${ONNXRUNTIME_BUILD_OPTIONS} --update
    BUILD_COMMAND <SOURCE_DIR>/build.sh ${ONNXRUNTIME_BUILD_OPTIONS} --build
    INSTALL_COMMAND cmake --install "<SOURCE_DIR>/build/Linux/${ONNXRUNTIME_BUILD_TYPE}" --prefix ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}_install/
)

install(
    DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}_install/
    DESTINATION ${CMAKE_INSTALL_PREFIX}
)

ament_export_include_directories(include/onnxruntime)
ament_export_libraries(onnxruntime)
ament_package()
