#!/bin/sh

set -e

env

# GitHub Personal Access Token
GITHUB_TOKEN="$GITHUB_TOKEN"

# Repository name
REPO="$GITHUB_REPOSITORY"

# Get the latest tag from GitHub

echo curl -s -H "Authorization: token $GITHUB_TOKEN" "$GITHUB_API_URL/repos/$REPO/tags
curl -s -H "Authorization: token $GITHUB_TOKEN" "$GITHUB_API_URL/repos/$REPO/tags

OLD_VERSION=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "$GITHUB_API_URL/repos/$REPO/tags" | jq -r '.[0].name' | awk -F'_' '{print $1}' | tr -d "v" | tr -d "uat-" | sort -V | tail -n 1)
echo "Old version: $OLD_VERSION"

# Extract major and minor version numbers
OLD_MAJOR_VERSION=$(echo $OLD_VERSION | awk -F'.' '{print $1}')
echo "Old major version: $OLD_MAJOR_VERSION"
OLD_MINOR_VERSION=$(echo $OLD_VERSION | awk -F'.' '{print $2}')
echo "Old minor version: $OLD_MINOR_VERSION"

# Generate new minor version
NEW_MINOR_VERSION=$(echo "$OLD_MINOR_VERSION + 1" | bc)
echo "New minor version: $NEW_MINOR_VERSION"

# Generate new version
TIMESTAMP=$(date +%Y%m%d)
echo "Current date: $TIMESTAMP"
NEW_VERSION="v$OLD_MAJOR_VERSION.$NEW_MINOR_VERSION.0_$TIMESTAMP"
echo "New release version will be: $NEW_VERSION"

# Create a new tag using GitHub API
curl -X POST \
     -H "Authorization: token $GITHUB_TOKEN" \
     -H "Content-Type: application/json" \
     -d "{\"tag\": \"$NEW_VERSION\",\"message\": \"Creating $NEW_VERSION\",\"object\": \"$GITHUB_SHA\",\"type\": \"commit\"}" \
     "https://api.github.com/repos/$REPO/git/tags"

## Create a reference for the new tag
curl -X POST \
     -H "Authorization: token $GITHUB_TOKEN" \
     -H "Content-Type: application/json" \
     -d "{\"ref\": \"refs/tags/$NEW_VERSION\",\"sha\": \"$GITHUB_SHA\"}" \
     "https://api.github.com/repos/$REPO/git/refs"
