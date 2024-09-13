#!/usr/bin/env bash
set -ex

# Get the latest commit hash
COMMIT_HASH=$(git rev-parse --short HEAD)

# Get the current timestamp adjusted to UTC+2
BUILD_TIME=$(date -u -d '+2 hour' +"%Y-%m-%d %H:%M:%S UTC+2")

# Replace the placeholders {{COMMIT_HASH}} and {{BUILD_TIME}} in index.html
if [[ "$OSTYPE" == "darwin"* ]]; then
  # For macOS
  sed -i '' "s/{{COMMIT_HASH}}/$COMMIT_HASH/" nginx/index.html
  sed -i '' "s/{{BUILD_TIME}}/$BUILD_TIME/" nginx/index.html
else
  # For Linux
  sed -i "s/{{COMMIT_HASH}}/$COMMIT_HASH/" nginx/index.html
  sed -i "s/{{BUILD_TIME}}/$BUILD_TIME/" nginx/index.html
fi

# Generate the info.json file
cat > nginx/info.json << EOF
{
  "commit_hash": "$COMMIT_HASH",
  "build_time": "$BUILD_TIME"
}
EOF
