#!/usr/bin/env bash
set -ex

# Get the current Git tag
GIT_TAG=$(git describe --tags --abbrev=0)

# Replace the placeholder {{GIT_TAG}} in index.html with the actual tag
sed -i "s/{{GIT_TAG}}/$GIT_TAG/" nginx/index.html
