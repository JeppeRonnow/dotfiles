#!/bin/bash

# Discord version updater script
# Updates the patch version (last number) in /opt/discord/resources/build_info.json
#
# Usage:
#   ./update_discord_version.sh          - Auto-increment patch version
#   ./update_discord_version.sh 0.0.125  - Set specific version

BUILD_INFO_FILE="/opt/discord/resources/build_info.json"

# Check if file exists
if [ ! -f "$BUILD_INFO_FILE" ]; then
  echo "Error: Build info file not found at $BUILD_INFO_FILE"
  exit 1
fi

# Extract current version
CURRENT_VERSION=$(sudo grep -oP '"version":\s*"\K[^"]+' "$BUILD_INFO_FILE")

if [ -z "$CURRENT_VERSION" ]; then
  echo "Error: Could not extract current version"
  exit 1
fi

echo "Current version: $CURRENT_VERSION"

# Determine new version
if [ -n "$1" ]; then
  # Manual version provided as argument
  NEW_VERSION="$1"

  # Validate version format (x.x.x)
  if [[ ! "$NEW_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Error: Invalid version format. Use format: x.x.x (e.g., 0.0.125)"
    exit 1
  fi

  echo "Setting version manually to: $NEW_VERSION"
else
  # Auto-increment patch version
  IFS='.' read -ra VERSION_PARTS <<<"$CURRENT_VERSION"
  MAJOR="${VERSION_PARTS[0]}"
  MINOR="${VERSION_PARTS[1]}"
  PATCH="${VERSION_PARTS[2]}"

  NEW_PATCH=$((PATCH + 1))
  NEW_VERSION="${MAJOR}.${MINOR}.${NEW_PATCH}"

  echo "Auto-incrementing to: $NEW_VERSION"
fi

# Create backup
sudo cp "$BUILD_INFO_FILE" "${BUILD_INFO_FILE}.backup"
echo "Backup created: ${BUILD_INFO_FILE}.backup"

# Update the version using sed
sudo sed -i "s/\"version\": \"$CURRENT_VERSION\"/\"version\": \"$NEW_VERSION\"/" "$BUILD_INFO_FILE"

# Verify the change
UPDATED_VERSION=$(sudo grep -oP '"version":\s*"\K[^"]+' "$BUILD_INFO_FILE")

if [ "$UPDATED_VERSION" = "$NEW_VERSION" ]; then
  echo "✓ Version successfully updated to $NEW_VERSION"
else
  echo "✗ Version update failed. Restoring backup..."
  sudo mv "${BUILD_INFO_FILE}.backup" "$BUILD_INFO_FILE"
  exit 1
fi
