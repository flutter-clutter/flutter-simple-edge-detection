cmake_minimum_required(VERSION 3.4.1)
include_directories(../include)
add_library(lib_opencv SHARED IMPORTED)
set_target_properties(lib_opencv PROPERTIES IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/src/main/jniLibs/${ANDROID_ABI}/libopencv_java4.so)
set(EDGE_DETECTION_DIR "../ios/Classes")
set(SOURCES
    ${EDGE_DETECTION_DIR}/native_edge_detection.cpp
    ${EDGE_DETECTION_DIR}/edge_detector.cpp
    ${EDGE_DETECTION_DIR}/image_processor.cpp
)
add_library(native_edge_detection SHARED ${SOURCES})
target_link_libraries(native_edge_detection lib_opencv)