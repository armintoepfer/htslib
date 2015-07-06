########################################################################
# CMake build script for htslib library.
########################################################################

project(htslib CXX C)
cmake_minimum_required(VERSION 3.2)

# project version
set(htslib_MAJOR_VERSION 1)
set(htslib_MINOR_VERSION 0)
set(htslib_PATCH_VERSION 0)
set(htslib_VERSION
  "${htslib_MAJOR_VERSION}.${htslib_MINOR_VERSION}.${htslib_PATCH_VERSION}"
)

# build-time options
option(htslib_build_shared "Build htslib as shared library."  OFF)

# determine if we are building a shared lib
if(htslib_build_shared)
    set(PB_LIB_MODE SHARED)
    set(PB_LIB_SUFFIX ${CMAKE_SHARED_LIBRARY_SUFFIX})
else()
    set(PB_LIB_MODE STATIC)
    set(PB_LIB_SUFFIX ${CMAKE_STATIC_LIBRARY_SUFFIX})
endif()

# main project paths
string(REPLACE "//" "/" HTS_LOCAL_DIR ${CMAKE_CURRENT_LIST_DIR})
set(htslib_RootDir       ${HTS_LOCAL_DIR} CACHE INTERNAL "bla" FORCE)
set(htslib_IncludeDir    ${htslib_RootDir} CACHE INTERNAL "bla" FORCE)
set(htslib_LibDir        ${htslib_RootDir} CACHE INTERNAL "bla" FORCE)

if (NOT ZLIB_INCLUDE_DIRS OR
    NOT ZLIB_LIBRARIES)
    find_package(ZLIB REQUIRED)
endif()

# shared CXX flags for src & tests
include(CheckCXXCompilerFlag)
set(htslib_CXX_FLAGS "-std=c++11 -Wall -Wextra -O3")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${htslib_CXX_FLAGS}")

string(REGEX REPLACE "/libz.*" "" ZLIB_LIBRARY_REPLACED ${ZLIB_LIBRARIES})
if(NOT TARGET htslibSrc)
add_custom_target(
    htslibSrc ALL
    "make" ZLIB_INC=${ZLIB_INCLUDE_DIR} ZLIB_DIR=${ZLIB_LIBRARY_REPLACED}
    COMMENT "cd ${htslib_RootDir} && make ZLIB_INC=${ZLIB_INCLUDE_DIR} ZLIB_DIR=${ZLIB_LIBRARY_REPLACED}"
    WORKING_DIRECTORY ${htslib_RootDir}
    VERBATIM
)

add_library(htslib STATIC IMPORTED)
add_dependencies(htslib htslibSrc)
endif()
# target_include_directories(htslib
#     INTERFACE
#     ${htslib_IncludeDir}
# )



# define symbols for projects that use htslib
set(HTSLIB_INCLUDE_DIRS
    ${htslib_IncludeDir}
    CACHE INTERNAL
    "${PROJECT_NAME}: Include Directories"
    FORCE
)

set(HTSLIB_LIBRARIES
    ${htslib_LibDir}/libhts${PB_LIB_SUFFIX}
    CACHE INTERNAL
    "${PROJECT_NAME}: Libraries"
    FORCE
)