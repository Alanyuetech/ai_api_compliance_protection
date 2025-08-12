#!/bin/bash

# Build script for all platforms using Docker
# This creates binaries for Linux and Windows

echo "========================================"
echo "Building AI Content Filter for all platforms"
echo "========================================"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed."
    echo "Please install Docker from: https://docs.docker.com/get-docker/"
    exit 1
fi

# Create bin directory
mkdir -p bin

echo ""
echo "Step 1: Building with Docker (this may take a few minutes)..."
echo "----------------------------------------------"

# Build the cross-compilation Docker image
docker build -f Dockerfile.cross -t ai-filter-cross:latest .

if [ $? -ne 0 ]; then
    echo "Docker build failed!"
    exit 1
fi

echo ""
echo "Step 2: Extracting compiled binaries..."
echo "----------------------------------------------"

# Create a temporary container and copy binaries
docker create --name temp-cross ai-filter-cross:latest
docker cp temp-cross:/output/ai-filter-linux ./bin/ai-filter-linux 2>/dev/null || echo "Linux binary not found"
docker cp temp-cross:/output/ai-filter-windows.exe ./bin/ai-filter-windows.exe 2>/dev/null || echo "Windows binary not found"
docker rm temp-cross

# Try the simpler Docker build as fallback for Linux
if [ ! -f "./bin/ai-filter-linux" ]; then
    echo ""
    echo "Fallback: Building Linux version with standard Dockerfile..."
    docker build -f Dockerfile -t ai-filter:latest .
    
    if [ $? -eq 0 ]; then
        docker create --name temp-linux ai-filter:latest
        docker cp temp-linux:/usr/local/bin/ai-filter ./bin/ai-filter-linux
        docker rm temp-linux
    fi
fi

# Make Linux binary executable
if [ -f "./bin/ai-filter-linux" ]; then
    chmod +x ./bin/ai-filter-linux
    echo "✅ Linux binary created: ./bin/ai-filter-linux"
fi

if [ -f "./bin/ai-filter-windows.exe" ]; then
    echo "✅ Windows binary created: ./bin/ai-filter-windows.exe"
fi

echo ""
echo "Step 3: Checking binary sizes..."
echo "----------------------------------------------"
ls -lh bin/

echo ""
echo "Step 4: Testing Linux binary..."
echo "----------------------------------------------"
if [ -f "./bin/ai-filter-linux" ]; then
    ./bin/ai-filter-linux --help || echo "Binary test failed"
fi

echo ""
echo "========================================"
echo "Build complete!"
echo ""
echo "Available binaries in ./bin/ directory:"
ls -1 bin/
echo ""
echo "Note: macOS binary requires building on a Mac or using GitHub Actions"
echo "========================================"