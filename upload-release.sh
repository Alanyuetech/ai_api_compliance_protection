#!/bin/bash

# Script to upload release to GitHub
# This script reads configuration from .env file

# Load environment variables from .env file
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
else
    echo "Error: .env file not found!"
    echo "Please create a .env file with your GitHub token."
    echo "You can copy .env.example as a template:"
    echo "  cp .env.example .env"
    echo "Then edit .env and add your GitHub token."
    exit 1
fi

# Check if GitHub token is set
if [ -z "$GITHUB_TOKEN" ] || [ "$GITHUB_TOKEN" = "ghp_REPLACE_WITH_YOUR_TOKEN" ]; then
    echo "Error: GITHUB_TOKEN not set in .env file!"
    echo "Please edit .env and add your GitHub personal access token."
    echo "You can create a token at: https://github.com/settings/tokens"
    exit 1
fi

VERSION="${VERSION:-v1.0.0}"
GITHUB_OWNER="${GITHUB_OWNER:-Alanyuetech}"
GITHUB_REPO="${GITHUB_REPO:-ai_api_compliance_protection}"

echo "========================================"
echo "Uploading AI Content Filter Release ${VERSION}"
echo "========================================"
echo "Repository: ${GITHUB_OWNER}/${GITHUB_REPO}"
echo ""

# Step 1: Push code using token
echo "Step 1: Pushing code to GitHub..."
git push https://${GITHUB_TOKEN}@github.com/${GITHUB_OWNER}/${GITHUB_REPO}.git master

if [ $? -ne 0 ]; then
    echo "Failed to push code. Please check your token and permissions."
    exit 1
fi

# Step 2: Configure GitHub CLI with token
echo ""
echo "Step 2: Configuring GitHub CLI..."
echo ${GITHUB_TOKEN} | gh auth login --with-token

# Step 3: Create release with binaries
echo ""
echo "Step 3: Creating GitHub Release ${VERSION}..."

RELEASE_NOTES="# AI Content Filter ${VERSION}

## 🎉 Release Notes

### Features
- 🚀 Ultra-fast content filtering (millisecond response)
- 📦 Lightweight binaries (Linux: 2.1MB, Windows: 1.8MB, macOS: 1.4MB)
- 🔒 Completely offline operation
- 🎯 Customizable filter rules with YAML
- 🌍 Cross-platform support

### Downloads
- **Linux**: \`ai-filter-linux\` - For Ubuntu/Debian/CentOS etc.
- **Windows**: \`ai-filter-windows.exe\` - For Windows 10/11
- **macOS**: \`ai-filter-macos\` - For macOS 10.15+

### Quick Start
\`\`\`bash
# Linux/macOS
chmod +x ai-filter-*
./ai-filter-* check \"test content\"

# Windows
ai-filter-windows.exe check \"test content\"
\`\`\`

### Configuration
See \`filter.example.yaml\` for custom rules configuration."

# Check if binaries exist
if [ ! -f "./bin/ai-filter-linux" ]; then
    echo "Warning: Linux binary not found at ./bin/ai-filter-linux"
fi

if [ ! -f "./bin/ai-filter-windows.exe" ]; then
    echo "Warning: Windows binary not found at ./bin/ai-filter-windows.exe"
fi

# Create release and upload files
RELEASE_FILES=""
[ -f "./bin/ai-filter-linux" ] && RELEASE_FILES="$RELEASE_FILES ./bin/ai-filter-linux"
[ -f "./bin/ai-filter-windows.exe" ] && RELEASE_FILES="$RELEASE_FILES ./bin/ai-filter-windows.exe"
[ -f "./bin/ai-filter-macos" ] && RELEASE_FILES="$RELEASE_FILES ./bin/ai-filter-macos"

if [ -z "$RELEASE_FILES" ]; then
    echo "Error: No binary files found to upload!"
    echo "Please run ./build-all-platforms.sh first to build the binaries."
    exit 1
fi

gh release create ${VERSION} \
    --repo ${GITHUB_OWNER}/${GITHUB_REPO} \
    --title "AI Content Filter ${VERSION}" \
    --notes "${RELEASE_NOTES}" \
    $RELEASE_FILES

if [ $? -eq 0 ]; then
    echo ""
    echo "========================================"
    echo "✅ Success! Release created at:"
    echo "https://github.com/${GITHUB_OWNER}/${GITHUB_REPO}/releases/tag/${VERSION}"
    echo "========================================"
else
    echo ""
    echo "Failed to create release. You can also manually create it at:"
    echo "https://github.com/${GITHUB_OWNER}/${GITHUB_REPO}/releases/new"
fi