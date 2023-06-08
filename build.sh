#!/bin/bash

set -e

# cleanup
rm -rf .build/ build/

# build for macOS
echo "Building for macOS..."
swift build --arch arm64 --arch x86_64 -c release -Xswiftc -O > /dev/null
mkdir -p "build/macOS"
rsync -ar ".build/apple/Products/Release/Shitmulation" "build/macOS"

# build for linux
if ! command -v docker &> /dev/null; then
    echo "Couldn't build for linux, docker isn't available"
    exit -1
fi

BUILD_CMD="swift build -c release -Xswiftc -O"

echo ""
echo "Building for Linux ARM64..."
docker container rm -f shitmulation-linux > /dev/null
docker run -it --name shitmulation-linux --platform linux/arm64/v8 -v $(pwd):/sources swift:latest /bin/bash -c "cd sources && $BUILD_CMD"
mkdir -p "build/linux-arm64"
rsync -ar ".build/aarch64-unknown-linux-gnu/release/Shitmulation" "build/linux-arm64"

echo ""
echo "Building for Linux x64..."
docker container rm -f shitmulation-linux > /dev/null
docker run -it --name shitmulation-linux --platform linux/amd64    -v $(pwd):/sources swift:latest /bin/bash -c "cd sources && $BUILD_CMD"
mkdir -p "build/linux-amd64"
rsync -ar ".build/x86_64-unknown-linux-gnu/release/Shitmulation"  "build/linux-amd64"

echo "All good!"
