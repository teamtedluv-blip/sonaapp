cmake_minimum_required(VERSION 3.14)

# Fix Visual Studio coroutine deprecation error
add_compile_definitions(_SILENCE_EXPERIMENTAL_COROUTINE_DEPRECATION_WARNINGS)

project(runner LANGUAGES CXX)

# The name of the executable created for the application.
set(BINARY_NAME "sona")

# Explicitly opt in to modern CMake behaviors.
cmake_policy(VERSION 3.14...3.25)

# Define build configuration.
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/runner")

# Configure the Flutter engine.
set(FLUTTER_MANAGED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/flutter")

add_subdirectory(${FLUTTER_MANAGED_DIR})

# Application build
add_executable(${BINARY_NAME}
  "flutter_window.cpp"
  "main.cpp"
  "utils.cpp"
  "win32_window.cpp"
  "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
)

# Apply standard Flutter Windows settings
apply_standard_settings(${BINARY_NAME})

# Add the runner directory
target_include_directories(${BINARY_NAME} PRIVATE
  "${CMAKE_CURRENT_SOURCE_DIR}"
)

# Flutter library linking
target_link_libraries(${BINARY_NAME} PRIVATE flutter flutter_wrapper_app)

# Ensure Flutter build happens before runner
add_dependencies(${BINARY_NAME} flutter_assemble)

# Windows application properties
set_target_properties(${BINARY_NAME} PROPERTIES
  WIN32_EXECUTABLE TRUE
)

# C++ standard
target_compile_features(${BINARY_NAME} PRIVATE cxx_std_17)

# Add required Windows libraries
target_link_libraries(${BINARY_NAME} PRIVATE
  shlwapi
)
