#############################
### Root CMake File       ###
### Date: 7 May 2025      ###
### Author: Fedi Nabli    ###
#############################

cmake_minimum_required(VERSION 3.20)
project(synapse LANGUAGES C CXX)

# -- Fetch Corrosion (Crago <-> CMake)
include(FetchContent)
FetchContent_Declare(
  Corrosion
  GIT_REPOSITORY https://github.com/corrosion-rs/corrosion.git
  GIT_TAG v0.5
)
FetchContent_MakeAvailable(Corrosion)

# -- Helper Modules
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
include(AddZig)
include(AddScriptTests)

# -- Rust Crate (staticlib)
corrosion_import_crate(
  MANIFEST_PATH ${CMAKE_SOURCE_DIR}/synapse_math/Cargo.toml
)

# -- Zig libraries
add_subdirectory(csv_parser)
add_subdirectory(json_parser)
add_subdirectory(synj_parser)

# -- C++ AI Engine
add_subdirectory(ai_engine)

# -- Enable testing
# add_subdirectory(scripts)
# enable_testing()
