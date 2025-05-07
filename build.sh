#!/bin/bash

check_tools() {
  if ! perl --version 2>&1 >/dev/null
  then
    echo "Perl is not installed, trying to install it..."
  else
    echo "Perl is installed"
    perl ./scripts/check_dependencies.pl

    if [ $? -ne 0 ]; then
      echo "Dependency check failed. Exiting..."
      exit 1
    fi
  fi
}

build_project() {
  echo "Removing Old build directories..."
  rm -rf build
  rm -rf bin
  echo "Creating build directories..."
  mkdir build
  echo "Building project..."
  cmake -S . -B build -G Ninja
  cmake --build build
  mkdir -p bin
  cp build/ai_engine/synapse bin/synapse
}

cleanup() {
  echo "Cleaning project..."
  echo "Removing build directory..."
  rm -rf build
  echo "Removing bin directory..."
  rm -rf bin
  echo "Cleaned up project"
}

if [[ "$1" == '-d' ]]; then
  cleanup
elif [[ "$1" == '-v' ]]; then
  check_tools
else
  check_tools
  build_project
fi
