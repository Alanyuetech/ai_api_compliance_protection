#!/bin/bash

# Build script for AI Content Filter
# This script compiles the project for multiple platforms

echo "Building AI Content Filter..."

# Check if Rust is installed
if ! command -v cargo &> /dev/null; then
    echo "Error: Rust is not installed."
    echo "Please install Rust from: https://rustup.rs/"
    exit 1
fi

# Create bin directory if it doesn't exist
mkdir -p bin

# Build for the current platform (optimized release)
echo "Building for current platform..."
cargo build --release

if [ $? -ne 0 ]; then
    echo "Build failed!"
    exit 1
fi

# Detect current platform
OS=$(uname -s)
ARCH=$(uname -m)

# Copy the binary to bin directory with appropriate name
if [ "$OS" = "Linux" ]; then
    cp target/release/ai-content-filter bin/ai-filter-linux
    echo "Linux binary created: bin/ai-filter-linux"
    chmod +x bin/ai-filter-linux
elif [ "$OS" = "Darwin" ]; then
    cp target/release/ai-content-filter bin/ai-filter-macos
    echo "macOS binary created: bin/ai-filter-macos"
    chmod +x bin/ai-filter-macos
elif [[ "$OS" == MINGW* ]] || [[ "$OS" == MSYS* ]] || [[ "$OS" == CYGWIN* ]]; then
    cp target/release/ai-content-filter.exe bin/ai-filter-windows.exe
    echo "Windows binary created: bin/ai-filter-windows.exe"
fi

# Optional: Cross-compile for other platforms
# Uncomment the sections below if you want to cross-compile

# # Cross-compile for Windows (from Linux/Mac)
# if [ "$OS" != "Windows" ]; then
#     echo "Cross-compiling for Windows..."
#     if rustup target list | grep -q "x86_64-pc-windows-gnu (installed)"; then
#         cargo build --release --target x86_64-pc-windows-gnu
#         if [ $? -eq 0 ]; then
#             cp target/x86_64-pc-windows-gnu/release/ai-content-filter.exe bin/ai-filter-windows.exe
#             echo "Windows binary created: bin/ai-filter-windows.exe"
#         fi
#     else
#         echo "Windows target not installed. Run: rustup target add x86_64-pc-windows-gnu"
#     fi
# fi

# # Cross-compile for Linux (from Mac/Windows)
# if [ "$OS" != "Linux" ]; then
#     echo "Cross-compiling for Linux..."
#     if rustup target list | grep -q "x86_64-unknown-linux-musl (installed)"; then
#         cargo build --release --target x86_64-unknown-linux-musl
#         if [ $? -eq 0 ]; then
#             cp target/x86_64-unknown-linux-musl/release/ai-content-filter bin/ai-filter-linux
#             chmod +x bin/ai-filter-linux
#             echo "Linux binary created: bin/ai-filter-linux"
#         fi
#     else
#         echo "Linux target not installed. Run: rustup target add x86_64-unknown-linux-musl"
#     fi
# fi

echo ""
echo "Build complete!"
echo "Binaries are located in the 'bin' directory"
echo ""
echo "To test the filter, run:"
echo "  ./bin/ai-filter-* check \"Test content\""