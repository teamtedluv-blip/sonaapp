cmake_minimum_required(VERSION 3.14)

add_compile_definitions(_SILENCE_EXPERIMENTAL_COROUTINE_DEPRECATION_WARNINGS)

project(runner LANGUAGES CXX)

set(BINARY_NAME "sona")

cmake_policy(VERSION 3.14...3.25)

# Configure the Flutter engine build.
set(FLUTTER_MANAGED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/flutter")

add_subdirectory(${FLUTTER_MANAGED_DIR})

# Application build
add_executable(${BINARY_NAME}
  "flutter_window.cpp"
  "main.cpp"
  "utils.cpp"
  "win32_window.cpp"
  "runner.exe.manifest"
)

# Apply the standard Windows configuration
apply_standard_settings(${BINARY_NAME})

# Add the Flutter plugin registrant
target_link_libraries(${BINARY_NAME} PRIVATE flutter flutter_wrapper_app)

# Add the runner files
target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}")

# Add dependencies
add_dependencies(${BINARY_NAME} flutter_assemble)

# Copy Flutter assets
set_target_properties(${BINARY_NAME} PROPERTIES
  WIN32_EXECUTABLE TRUE
)

# Ensure the correct C++ standard
target_compile_features(${BINARY_NAME} PRIVATE cxx_std_17)
