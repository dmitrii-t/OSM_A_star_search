# cairo-io2d-compatibility.cmake

# First, find cairo using PkgConfig as suggested by vcpkg
find_package(PkgConfig REQUIRED)
pkg_check_modules(cairo REQUIRED IMPORTED_TARGET cairo)

# Check if the target already exists before creating it
if(NOT TARGET unofficial::cairo::cairo)
    add_library(unofficial::cairo::cairo INTERFACE IMPORTED)
    set_target_properties(unofficial::cairo::cairo PROPERTIES
        INTERFACE_LINK_LIBRARIES PkgConfig::cairo
    )
endif()

# Create an alias target Cairo::Cairo that io2d is expecting
if(NOT TARGET Cairo::Cairo)
    add_library(Cairo::Cairo ALIAS unofficial::cairo::cairo)
endif()

# Set variables to indicate this compatibility script has run
set(unofficial-cairo_FOUND TRUE)
set(unofficial-cairo_VERSION ${cairo_VERSION})
set(Cairo_FOUND TRUE)
set(Cairo_VERSION ${cairo_VERSION})

# Create a dummy config file
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/unofficial-cairoConfig.cmake"
"
include(CMakeFindDependencyMacro)
find_dependency(PkgConfig)

if(NOT TARGET unofficial::cairo::cairo)
    add_library(unofficial::cairo::cairo INTERFACE IMPORTED)
    set_target_properties(unofficial::cairo::cairo PROPERTIES
        INTERFACE_LINK_LIBRARIES PkgConfig::cairo
    )
endif()

if(NOT TARGET Cairo::Cairo)
    add_library(Cairo::Cairo ALIAS unofficial::cairo::cairo)
endif()
")

# Set the location of the config file
set(unofficial-cairo_DIR "${CMAKE_CURRENT_BINARY_DIR}" CACHE PATH "Path to unofficial-cairoConfig.cmake" FORCE)
set(Cairo_DIR "${CMAKE_CURRENT_BINARY_DIR}" CACHE PATH "Path to CairoConfig.cmake" FORCE)