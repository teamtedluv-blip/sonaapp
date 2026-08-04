cmake_minimum_required(VERSION 3.14)

# Fix Visual Studio experimental coroutine deprecation error
add_compile_definitions(_SILENCE_EXPERIMENTAL_COROUTINE_DEPRECATION_WARNINGS)

project(runner LANGUAGES CXX)

set(BINARY_NAME "sona")

cmake_policy(VERSION 3.14...3.25)

# Configure build options.
get_property(BUILD_OPTIONS GLOBAL PROPERTY BUILDSYSTEM_TARGETS)

# The directory where the Flutter engine is located.
set(FLUTTER_MANAGED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/flutter")

# Add Flutter generated CMake.
add_subdirectory(${FLUTTER_MANAGED_DIR})

# Runner executable
add_executable(${BINARY_NAME}
  "flutter_window.cpp"
  "main.cpp"
  "utils.cpp"
  "win32_window.cpp"
  "Runner.rc"
  "runner.exe.manifest"
)

# Apply Flutter Windows settings
apply_standard_settings(${BINARY_NAME})

# Include runner files
target_include_directories(${BINARY_NAME} PRIVATE
  "${CMAKE_CURRENT_SOURCE_DIR}"
)

# Link Flutter
target_link_libraries(${BINARY_NAME} PRIVATE
  flutter
  flutter_wrapper_app
)

# Make sure Flutter is built first
add_dependencies(${BINARY_NAME}
  flutter_assemble
)

# Windows executable
set_target_properties(${BINARY_NAME} PROPERTIES
  WIN32_EXECUTABLE TRUE
)

# Use C++17
target_compile_features(${BINARY_NAME} PRIVATE cxx_std_17)

# Windows system libraries
target_link_libraries(${BINARY_NAME} PRIVATE
  dwmapi
)
