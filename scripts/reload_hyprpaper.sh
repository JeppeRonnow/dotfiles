#!/usr/bin/env bash

# reloadpaper - reloads Hyprpaper with a fixed wallpaper

# Set your wallpaper path here
WALL="$HOME/.config/themes/current/img/background2.png"

# Check if the file exists
if [ ! -f "$WALL" ]; then
  echo "❌ Error: Wallpaper not found at $WALL"
  exit 1
fi

echo "🔁 Reloading Hyprpaper..."

# Kill any running Hyprpaper instance
pkill hyprpaper 2>/dev/null

# Wait a bit to ensure it's stopped
sleep 0.3

# Start Hyprpaper in background
hyprpaper &

# Give it a moment to start
sleep 0.5

# Preload and set wallpaper
hyprctl hyprpaper preload "$WALL"
hyprctl hyprpaper wallpaper ",$WALL"

echo "✅ Wallpaper reloaded: $WALL"
