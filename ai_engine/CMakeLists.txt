#############################
### AI Engine C++ CMake   ###
### Date: 7 May 2025      ###
### Modified: 10 May 2025 ###
### Author: Fedi Nabli    ###
#############################

add_library(ai_engine STATIC
  src/data/csv.cc
  src/data/json.cc
  src/data/synj.cc
)

target_compile_features(ai_engine PUBLIC cxx_std_17)

target_link_libraries(ai_engine
  PUBLIC
      csv json synj # Zig parsers
      synapse_math # Rust math library
)

target_include_directories(ai_engine PRIVATE
  ${CMAKE_CURRENT_BINARY_DIR} # headers ommited by Zig
  ${CMAKE_BINARY_DIR}/rust # Corrosion places Rust headers here
  ${CMAKE_SOURCE_DIR}/ai_engine/includes # Cpp header files
)

set_target_properties(ai_engine PROPERTIES
  CXX_STANDARD 17
  CXX_STANDARD_REQUIRED YES
  CXX_EXTENSIONS NO
)

# final executable
add_executable(synapse src/main.cc)
target_compile_features(synapse PRIVATE cxx_std_17)

target_include_directories(synapse PRIVATE
  ${CMAKE_CURRENT_SOURCE_DIR}/includes
)

target_link_libraries(synapse PRIVATE ai_engine)
if (APPLE)
  target_link_options(synapse PRIVATE -Wl,-no_warn_duplicate_libraries)
endif()
