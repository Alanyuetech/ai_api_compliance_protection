#!/bin/bash

# Script to trigger macOS build via GitHub Actions
# This script reads token from .env file

echo "========================================"
echo "Building macOS Binary via GitHub Actions"
echo "========================================"

# Load environment variables from .env file
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
    echo "✅ Loaded configuration from .env"
else
    echo "❌ Error: .env file not found!"
    echo "Please create a .env file with your GitHub token."
    exit 1
fi

# Check if GitHub token is set
if [ -z "$GITHUB_TOKEN" ] || [ "$GITHUB_TOKEN" = "ghp_REPLACE_WITH_YOUR_TOKEN" ]; then
    echo "❌ Error: GITHUB_TOKEN not properly set in .env file!"
    exit 1
fi

GITHUB_OWNER="${GITHUB_OWNER:-Alanyuetech}"
GITHUB_REPO="${GITHUB_REPO:-ai_api_compliance_protection}"

echo "Repository: ${GITHUB_OWNER}/${GITHUB_REPO}"
echo ""

# GitHub CLI will use GITHUB_TOKEN environment variable automatically
echo "Step 1: Checking GitHub authentication..."
gh auth status 2>/dev/null

if [ $? -ne 0 ]; then
    echo "Setting up GitHub CLI authentication..."
    # Clear any existing auth
    gh auth logout --hostname github.com 2>/dev/null || true
    # Login with token
    echo ${GITHUB_TOKEN} | gh auth login --with-token
    
    if [ $? -ne 0 ]; then
        echo "❌ Failed to authenticate with GitHub"
        exit 1
    fi
fi

echo "✅ GitHub authentication ready"
echo ""

# Trigger the macOS build workflow
echo "Step 2: Triggering macOS build workflow..."
gh workflow run build-macos-simple.yml --repo ${GITHUB_OWNER}/${GITHUB_REPO}

if [ $? -eq 0 ]; then
    echo "✅ Workflow triggered successfully!"
    echo ""
    echo "Step 3: Monitoring build progress..."
    echo "Waiting for workflow to start..."
    sleep 10
    
    # Get the latest run ID
    RUN_ID=$(gh run list --workflow=build-macos-simple.yml --repo ${GITHUB_OWNER}/${GITHUB_REPO} --limit 1 --json databaseId --jq '.[0].databaseId')
    
    if [ -n "$RUN_ID" ]; then
        echo "Build started with Run ID: $RUN_ID"
        echo "You can monitor progress at:"
        echo "https://github.com/${GITHUB_OWNER}/${GITHUB_REPO}/actions/runs/${RUN_ID}"
        echo ""
        echo "Waiting for build to complete (this may take 2-3 minutes)..."
        
        # Wait for workflow to complete
        gh run watch $RUN_ID --repo ${GITHUB_OWNER}/${GITHUB_REPO} --exit-status
        
        if [ $? -eq 0 ]; then
            echo ""
            echo "✅ Build completed successfully!"
            echo ""
            echo "Step 4: Downloading macOS binary..."
            
            # Download the artifact
            gh run download $RUN_ID --repo ${GITHUB_OWNER}/${GITHUB_REPO} --dir ./temp-download
            
            if [ -f "./temp-download/ai-filter-macos/ai-filter-macos" ]; then
                # Move to bin directory
                cp ./temp-download/ai-filter-macos/ai-filter-macos ./bin/ai-filter-macos
                chmod +x ./bin/ai-filter-macos
                rm -rf ./temp-download
                
                echo "✅ macOS binary downloaded to ./bin/ai-filter-macos"
                echo ""
                echo "File info:"
                ls -lah ./bin/ai-filter-macos
                file ./bin/ai-filter-macos
            else
                echo "❌ Failed to find macOS binary in download"
            fi
        else
            echo "❌ Build failed. Check the workflow logs for details."
        fi
    else
        echo "❌ Could not get workflow run ID"
    fi
else
    echo "❌ Failed to trigger workflow"
    exit 1
fi

echo ""
echo "========================================"
echo "Process complete!"
echo "========================================"