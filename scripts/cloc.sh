#!/bin/bash

cloc ai_engine cmake csv_parser/src csv_parser/includes csv_parser/CMakeLists.txt csv_parser/build.zig \
  json_parser/src json_parser/includes json_parser/CMakeLists.txt json_parser/build.zig scripts \
  synapse_math/src synapse_math/include synj_parser/src synj_parser/includes synj_parser/CMakeLists.txt synj_parser/build.zig \
  build.sh cloc.sh CMakeLists.txt
