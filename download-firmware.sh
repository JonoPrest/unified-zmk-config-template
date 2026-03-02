#!/bin/bash

# Download build artifacts for the current commit to firmware/

# Get current commit SHA
COMMIT_SHA=$(git rev-parse HEAD)
SHORT_SHA=$(git rev-parse --short HEAD)

echo "Current commit: $SHORT_SHA"
echo "Searching for build matching this commit..."

# Find the workflow run for this specific commit
RUN_ID=$(gh run list --workflow=build.yml --commit="$COMMIT_SHA" --json databaseId,status,conclusion --jq '.[] | select(.conclusion=="success") | .databaseId' | head -1)

if [ -z "$RUN_ID" ]; then
	echo "Error: No successful build found for commit $SHORT_SHA"
	echo "The build may still be running or failed. Check with: gh run list"
	exit 1
fi

echo "Found build run: $RUN_ID"
echo "Downloading artifacts..."

# Download artifacts
gh run download "$RUN_ID" --dir .

# Move files if they're in a nested directory
if [ -d "firmware" ] && [ -f "firmware/corne_left-nice_nano_v2-zmk.uf2" ]; then
	echo "✓ Firmware downloaded successfully!"
	ls -lh firmware/*.uf2
else
	echo "✓ Firmware files downloaded!"
	ls -lh *.uf2 2>/dev/null || echo "Note: Firmware files may be in a subdirectory"
fi
