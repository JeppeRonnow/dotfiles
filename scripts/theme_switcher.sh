#!/bin/bash

THEMES_DIR="$HOME/.config/themes"
CURRENT_DIR="$THEMES_DIR/current"
THEME_NAME="$1"
SOURCE_DIR="$THEMES_DIR/$THEME_NAME"

# Ensure a theme name is provided
if [ -z "$THEME_NAME" ]; then
  echo "Usage: $0 <theme-name>"
  echo "Available themes:"
  ls "$THEMES_DIR"
  exit 1
fi

# Verify that the source theme exists and is a directory
if [ ! -d "$SOURCE_DIR" ]; then
  echo "Error: Theme '$THEME_NAME' not found in $THEMES_DIR"
  exit 1
fi

# Verify that the current directory exists and is inside the themes directory
if [ ! -d "$CURRENT_DIR" ]; then
  echo "Error: '$CURRENT_DIR' does not exist. Creating it..."
  mkdir -p "$CURRENT_DIR"
fi

# Safety check: make sure CURRENT_DIR actually points inside THEMES_DIR
if [[ "$CURRENT_DIR" != "$THEMES_DIR/"* ]]; then
  echo "Safety check failed — current dir not inside $THEMES_DIR"
  exit 1
fi

# Copy files from the chosen theme into current, overwriting existing ones
echo "Copying theme '$THEME_NAME' into '$CURRENT_DIR' (overwriting existing files)..."
cp -rT "$SOURCE_DIR" "$CURRENT_DIR" 2>/dev/null || cp -r "$SOURCE_DIR"/* "$CURRENT_DIR"/

./reload_hyprpaper.sh

echo "✅ Theme switched to '$THEME_NAME' successfully!"
