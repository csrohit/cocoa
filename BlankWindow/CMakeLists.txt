# CMakeLists.txt
cmake_minimum_required(VERSION 3.27)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Set the project name
project(MyCocoaApp)

# Set the minimum macOS version
set(CMAKE_OSX_DEPLOYMENT_TARGET "10.12" CACHE STRING "Minimum macOS version" FORCE)

# Find the Cocoa framework
find_library(COCOA_FRAMEWORK Cocoa)


file(GLOB SOURCE_FILES src/*.m src/*.h)

# Create the executable
add_executable(${PROJECT_NAME} ${SOURCE_FILES})
include_directories(include)

# Link the Cocoa framework
target_link_libraries(${PROJECT_NAME} ${COCOA_FRAMEWORK})

# Create the symbolic link
file(CREATE_LINK ${CMAKE_BINARY_DIR}/compile_commands.json ${CMAKE_SOURCE_DIR}/compile_commands.json SYMBOLIC)
