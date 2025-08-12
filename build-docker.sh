#!/bin/bash

# Build AI Content Filter using Docker
# This script doesn't require Rust to be installed locally

echo "Building AI Content Filter with Docker..."
echo "========================================="

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed."
    echo "Please install Docker from: https://docs.docker.com/get-docker/"
    exit 1
fi

# Create bin directory if it doesn't exist
mkdir -p bin

# Build the Docker image
echo "Building Docker image..."
docker build -t ai-content-filter:latest .

if [ $? -ne 0 ]; then
    echo "Docker build failed!"
    exit 1
fi

# Extract the binary from the container
echo "Extracting binary..."
docker create --name temp-filter ai-content-filter:latest
docker cp temp-filter:/usr/local/bin/ai-filter ./bin/ai-filter-linux
docker rm temp-filter

# Make it executable
chmod +x ./bin/ai-filter-linux

echo ""
echo "Build complete!"
echo "Binary created: ./bin/ai-filter-linux"
echo ""
echo "To test the filter, run:"
echo "  ./bin/ai-filter-linux check \"Test content\""
echo ""
echo "To run with Docker directly:"
echo "  docker run --rm ai-content-filter:latest check \"Test content\""