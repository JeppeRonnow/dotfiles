#!/usr/bin/env bash
#
# reload_swayosd — Restart swayosd-server with local config and theme
#

set -e

APP="swayosd-server"
CONFIG_FILE="$HOME/.config/swayosd/config.toml"
STYLE_FILE="$HOME/.config/themes/current/swayosd.css"

# ---------------------------------------------------------------------
# 1️⃣ Ensure config and style files exist
echo "🔍 Checking SwayOSD config and style..."

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "⚠️  Config file not found: $CONFIG_FILE"
else
  echo "✅ Config found: $CONFIG_FILE"
fi

if [[ ! -f "$STYLE_FILE" ]]; then
  echo "⚠️  Style file not found: $STYLE_FILE"
else
  echo "✅ Style found: $STYLE_FILE"
fi

# ---------------------------------------------------------------------
# 2️⃣ Restart swayosd-server via uwsm
echo "🔁 Restarting $APP..."
pkill -x "$APP" 2>/dev/null || true
sleep 0.5

setsid uwsm app -- "$APP" --config "$CONFIG_FILE" --style "$STYLE_FILE" >/dev/null 2>&1 &

sleep 0.5
if pgrep -x "$APP" >/dev/null; then
  echo "✅ $APP restarted successfully!"
  echo "   config → $CONFIG_FILE"
  echo "   style  → $STYLE_FILE"
else
  echo "❌ Failed to start $APP."
fi
