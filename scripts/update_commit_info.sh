#!/usr/bin/env bash
set -ex

# Get the latest commit hash
COMMIT_HASH=$(git rev-parse --short HEAD)

# Get the current timestamp in a human-readable format
BUILD_TIME=$(date -u +"%Y-%m-%d %H:%M:%S UTC")

# Replace the placeholders {{COMMIT_HASH}} and {{BUILD_TIME}} in index.html
# This version of `sed` works both on Linux and macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
  # For macOS, use the `-i ''` argument to avoid issues with sed in-place editing
  sed -i '' "s/{{COMMIT_HASH}}/$COMMIT_HASH/" nginx/index.html
  sed -i '' "s/{{BUILD_TIME}}/$BUILD_TIME/" nginx/index.html
else
  # For Linux, the `-i` argument works fine
  sed -i "s/{{COMMIT_HASH}}/$COMMIT_HASH/" nginx/index.html
  sed -i "s/{{BUILD_TIME}}/$BUILD_TIME/" nginx/index.html
fi
