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
    "--allow_running_as_root"
    ${ONNXRUNTIME_EXTRA_OPTS}
)

# If /usr/local/cuda exists, enable CUDA by default
if(EXISTS "/usr/local/cuda")
    list(APPEND ONNXRUNTIME_BUILD_OPTIONS "--use_cuda" "--cuda_home" "/usr/local/cuda")
endif()

# If /usr/src/tensorrt exists, enable TensorRT by default
if(EXISTS "/usr/src/tensorrt")
    list(APPEND ONNXRUNTIME_BUILD_OPTIONS "--use_tensorrt" "--tensorrt_home" "/usr/src/tensorrt")
endif()

# If /opt/rocm/lib/migraphx exists, enable MIGraphX by default
if(EXISTS "/opt/rocm")
    list(APPEND ONNXRUNTIME_BUILD_OPTIONS "--use_migraphx" "--migraphx_home" "/opt/rocm")
endif()

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
