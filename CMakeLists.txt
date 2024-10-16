cmake_minimum_required(VERSION 3.11.3)

# Set the C++ standard we will use
set(CMAKE_CXX_STANDARD 17)

# force dynamic liking
set(BUILD_SHARED_LIBS on)

# Vcpkg setup
set(CMAKE_TOOLCHAIN_FILE $ENV{VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake)
set(CMAKE_PREFIX_PATH $ENV{VCPKG_ROOT}/installed/x64-windows)

# Add the path of the cmake files to the CMAKE_MODULE_PATH
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_SOURCE_DIR}/cmake)

project(OSM_A_star_search)

# Set library output path to /lib
set(LIBRARY_OUTPUT_PATH "${CMAKE_SOURCE_DIR}/lib")

# Include io2d compatibility script
set(CAIRO_COMPATIBILITY_SCRIPT "${CMAKE_CURRENT_SOURCE_DIR}/cairo-io2d-compatibility.cmake")
if(EXISTS "${CAIRO_COMPATIBILITY_SCRIPT}")
    include("${CAIRO_COMPATIBILITY_SCRIPT}")
else()
    message(FATAL_ERROR "cairo-io2d-compatibility.cmake not found. Please ensure it exists in the project root directory.")
endif()

# Locate project prerequisites
find_package(io2d REQUIRED)
find_package(Cairo)
find_package(GraphicsMagick)

# Set IO2D flags
set(IO2D_WITHOUT_SAMPLES 1)
set(IO2D_WITHOUT_TESTS 1)

# Add the pugixml and GoogleTest library subdirectories
add_subdirectory(thirdparty/pugixml)
# Configure pugixml for shared library
set_target_properties(pugixml PROPERTIES
    POSITION_INDEPENDENT_CODE ON
    DEBUG_POSTFIX "d"
)

# Add GoogleTest
add_subdirectory(thirdparty/googletest)
# Configure GTest for shared library
set_target_properties(gtest gtest_main PROPERTIES
    POSITION_INDEPENDENT_CODE ON
    DEBUG_POSTFIX "d"
)

# Add project executable
add_executable(OSM_A_star_search src/main.cpp src/model.cpp src/render.cpp src/route_model.cpp src/route_planner.cpp)

# Set up the DLL copy commands for the main executable
if(MSVC)
    add_custom_command(TARGET OSM_A_star_search POST_BUILD
        # Copy pugixml DLL
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            $<TARGET_FILE:pugixml>
            $<TARGET_FILE_DIR:OSM_A_star_search>
    )
endif()

target_link_libraries(OSM_A_star_search
    PRIVATE io2d::io2d
    PUBLIC pugixml
)

# Add the testing executable
add_executable(test test/utest_rp_a_star_search.cpp src/route_planner.cpp src/model.cpp src/route_model.cpp)

# Set up the DLL copy commands for the test executable
if(MSVC)
    add_custom_command(TARGET test POST_BUILD
        # Copy pugixml DLL
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            $<TARGET_FILE:pugixml>
            $<TARGET_FILE_DIR:test>
        # Copy GTest DLLs
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            $<TARGET_FILE:gtest>
            $<TARGET_FILE_DIR:test>
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            $<TARGET_FILE:gtest_main>
            $<TARGET_FILE_DIR:test>
    )
endif()

target_link_libraries(test 
    gtest_main 
    pugixml
)

# Set options for Linux or Microsoft Visual C++
if( ${CMAKE_SYSTEM_NAME} MATCHES "Linux" )
    target_link_libraries(OSM_A_star_search PUBLIC pthread)
endif()

if(MSVC)
	target_compile_options(OSM_A_star_search PUBLIC /D_SILENCE_CXX17_ALLOCATOR_VOID_DEPRECATION_WARNING /wd4459)
endif()
