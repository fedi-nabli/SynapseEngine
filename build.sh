#!/bin/sh

echo "Removing Old build directory..."
rm -rf build
echo "Creating build directory..."
mkdir build
echo "Building project..."
cmake -S . -B build -G Ninja
cmake --build build
