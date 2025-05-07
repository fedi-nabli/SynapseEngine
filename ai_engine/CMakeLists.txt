#############################
### AI Engine C++ CMake   ###
### Date: 7 May 2025      ###
### Author: Fedi Nabli    ###
#############################

add_library(ai_engine STATIC
  src/main.cc
)

target_link_libraries(ai_engine
  PUBLIC
      csv json synj # Zig parsers
      synapse_math # Rust math library
)

target_include_directories(ai_engine PRIVATE
  ${CMAKE_CURRENT_BINARY_DIR} # headers ommited by Zig
  ${CMAKE_BINARY_DIR}/rust # Corrosion places Rust headers here
)

set_property(TARGET ai_engine PROPERTY CXX_STANDARD 17)

# final executable
add_executable(synapse src/main.cc)
target_link_libraries(synapse PRIVATE ai_engine)
if (APPLE)
  target_link_options(synapse PRIVATE -Wl,-no_warn_duplicate_libraries)
endif()
