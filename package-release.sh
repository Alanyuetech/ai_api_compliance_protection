#!/bin/bash

# Package release binaries for distribution

VERSION=${1:-"1.0.0"}
RELEASE_DIR="release-v${VERSION}"

echo "Packaging AI Content Filter v${VERSION}..."

# Create release directory
mkdir -p "${RELEASE_DIR}"

# Check if binaries exist
if [ ! -f "./bin/ai-filter-linux" ]; then
    echo "Error: Linux binary not found. Run ./build-all-platforms.sh first"
    exit 1
fi

# Copy binaries
cp ./bin/ai-filter-linux "${RELEASE_DIR}/"
cp ./bin/ai-filter-windows.exe "${RELEASE_DIR}/" 2>/dev/null || echo "Windows binary not found"

# Copy documentation
cp README.md "${RELEASE_DIR}/"
cp filter.example.yaml "${RELEASE_DIR}/"
cp LICENSE "${RELEASE_DIR}/"

# Create checksums
cd "${RELEASE_DIR}"
sha256sum * > checksums.txt
cd ..

# Create archives
echo "Creating archives..."

# Linux archive
tar -czf "ai-filter-linux-v${VERSION}.tar.gz" -C "${RELEASE_DIR}" ai-filter-linux README.md filter.example.yaml LICENSE

# Windows archive (if exists)
if [ -f "${RELEASE_DIR}/ai-filter-windows.exe" ]; then
    zip -j "ai-filter-windows-v${VERSION}.zip" \
        "${RELEASE_DIR}/ai-filter-windows.exe" \
        "${RELEASE_DIR}/README.md" \
        "${RELEASE_DIR}/filter.example.yaml" \
        "${RELEASE_DIR}/LICENSE"
fi

# Create a combined archive
tar -czf "ai-filter-all-v${VERSION}.tar.gz" "${RELEASE_DIR}/"

echo ""
echo "Release packages created:"
ls -lh ai-filter-*.tar.gz ai-filter-*.zip 2>/dev/null
echo ""
echo "Checksums:"
cat "${RELEASE_DIR}/checksums.txt"
echo ""
echo "Ready to upload to GitHub Releases!"