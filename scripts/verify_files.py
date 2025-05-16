import os
import sys

REQUIRED_FILES = [
  'ai_engine/includes/data/csv.hpp',
  'ai_engine/includes/data/json.hpp',
  'ai_engine/src/data/csv.cc',
  'ai_engine/src/data/json.cc',
  'ai_engine/src/main.cc',
  'ai_engine/CMakeLists.txt',
  'cmake/AddScriptTests.cmake',
  'cmake/AddZig.cmake',
  'cmake/CopyMathHeader.cmake',
  'csv_parser/includes/csv.h',
  'csv_parser/src/csv.zig',
  'csv_parser/src/error.zig',
  'csv_parser/src/parser.zig',
  'csv_parser/src/root.zig',
  'csv_parser/build.zig',
  'csv_parser/CMakeLists.txt',
  'json_parser/includes/json.h',
  'json_parser/src/error.zig',
  'json_parser/src/json.zig',
  'json_parser/src/parser.zig',
  'json_parser/src/root.zig',
  'json_parser/build.zig',
  'json_parser/CMakeLists.txt',
  'scripts/check_dependencies.pl',
  'scripts/cloc.sh',
  'scripts/verify_dependencies.sh',
  'scripts/verify_tool_versions.py',
  'synapse_math/include/math/synapse_math.h',
  'synapse_math/src/lib.rs',
  'synapse_math/Cargo.toml',
  'synj_parser/includes/synj.h',
  'synj_parser/src/error.zig',
  'synj_parser/src/helper.zig',
  'synj_parser/src/lexer.zig',
  'synj_parser/src/node.zig',
  'synj_parser/src/parser.zig',
  'synj_parser/src/root.zig',
  'synj_parser/src/synj.zig',
  'synj_parser/src/tokenizer.zig',
  'synj_parser/build.zig',
  'synj_parser/CMakeLists.txt',
  'tests/test.csv',
  '.gitignore',
  'build.sh',
  'CMakeLists.txt',
  'README.md'
]

def main():
  missing_files = []

  for file_path in REQUIRED_FILES:
    if not os.path.isfile(file_path):
      missing_files.append(file_path)

  if len(missing_files) > 0:
    print("ERROR: The following files are missing:")
    for file in missing_files:
      print(f"  - {file}")
    sys.exit(1)

  print("All required files are present.")
  sys.exit(0)

if __name__ == '__main__':
  main()
