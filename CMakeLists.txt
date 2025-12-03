cmake_minimum_required(VERSION 3.16)
project(onnxruntime_vendor)

find_package(ament_cmake REQUIRED)
include(FetchContent)

ament_package_xml()
set(ONNXRUNTIME_VERSION "${${PROJECT_NAME}_VERSION}")
message(STATUS "ONNXRUNTIME_VERSION: ${ONNXRUNTIME_VERSION}")

option(ONNXRUNTIME_PREBUILT "Use prebuilt ONNX Runtime binaries" OFF)

if(ONNXRUNTIME_PREBUILT STREQUAL "ON")
  include("${CMAKE_CURRENT_LIST_DIR}/onnxruntime-prebuilt.cmake")
else()
  include("${CMAKE_CURRENT_LIST_DIR}/onnxruntime-build.cmake")
endif()
