# set minimum required cmake version
cmake_minimum_required(VERSION 3.20)

if(${CMAKE_VERSION} VERSION_LESS 3.20)
  cmake_policy(VERSION ${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION})
else()
  cmake_policy(VERSION 3.20)
endif()

# generate compilation database for Ninja and Makefile generators Visual studio
# does not support this
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# default build configuration
set(default_build_type "Release")
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  message(
    STATUS
      "Setting build type to '${default_build_type}' as none was specified.")
  set(CMAKE_BUILD_TYPE
      "${default_build_type}"
      CACHE STRING "Choose the type of build." FORCE)
  # Set the possible values of build type for cmake-gui
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release"
                                               "MinSizeRel" "RelWithDebInfo")
endif()

# set CPP standard
set(CMAKE_CXX_STANDARD
    11
    CACHE STRING "The C++ standard to use")
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF) # this ensures -std=c++11 instead of -std=g++11

if(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -Wextra -Wunused-variable")
elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra -Wunused-variable")
elseif(MSVC)
  # For MSVC, /we4101 treats unused variables as errors
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /W4 /we4101")
endif()

# Project metadata
project(
  sphere
  VERSION 1.0
  DESCRIPTION "Three Moving lights"
  LANGUAGES CXX)

file(GLOB SOURCE_FILES src/*.mm src/*.cpp)
# create an executable with source file
add_executable(${PROJECT_NAME} ${SOURCE_FILES})


# find OpenGL library
find_package(OpenGL REQUIRED)
find_library(COCOA_FRAMEWORK Cocoa)
find_library(COREVIDEO_FRAMEWORK QuartzCore)

target_compile_definitions(${PROJECT_NAME} PUBLIC GL_SILENCE_DEPRECATION)
target_compile_options(${PROJECT_NAME} PRIVATE -Wno-deprecated-declarations)

target_include_directories(${PROJECT_NAME} PUBLIC include)

# link with libraries
target_link_libraries(${PROJECT_NAME} PRIVATE OpenGL::GL ${COCOA_FRAMEWORK} ${COREVIDEO_FRAMEWORK})

# avoid building in source directory
file(TO_CMAKE_PATH "${PROJECT_BINARY_DIR}/CMakeLists.txt" LOC_PATH)
if(EXISTS "${LOC_PATH}")
  message(
    FATAL_ERROR
      "You cannot build in a source directory (or any directory with a CMakeLists.txt file). Please make a build subdirectory. Feel free to remove CMakeCache.txt and CMakeFiles."
  )
endif()

# Create the symbolic link for compilation database [used for clangd
# intelisence]
if(EXISTS ${CMAKE_BINARY_DIR}/compile_commands.json)
  file(CREATE_LINK ${CMAKE_BINARY_DIR}/compile_commands.json
       ${CMAKE_SOURCE_DIR}/compile_commands.json SYMBOLIC)
endif()
