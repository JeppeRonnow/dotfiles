#!/usr/bin/env bash

# Directory containing your scripts
SCRIPT_DIR="$HOME/dotfiles/.config/themes/change_theme/"

# Rofi theme directory and file
THEME_DIR="$HOME/.config/themes/current/"
THEME="rofi"

# Make sure the script directory exists
if [[ ! -d "$SCRIPT_DIR" ]]; then
  notify-send "Error" "Script directory not found: $SCRIPT_DIR"
  exit 1
fi

# Find executable scripts (ignores directories)
SCRIPTS=$(find "$SCRIPT_DIR" -maxdepth 1 -type f -executable -printf "%f\n")

# If no scripts found
if [[ -z "$SCRIPTS" ]]; then
  notify-send "No scripts found" "No executable scripts in $SCRIPT_DIR"
  exit 0
fi

# Launch rofi to pick a script using your custom theme
SELECTED=$(echo "$SCRIPTS" | rofi -dmenu -i -p "Select theme:" -theme "${THEME_DIR}/${THEME}.rasi")

# If user cancelled
[[ -z "$SELECTED" ]] && exit 0

# Run the selected script silently in the background
"$SCRIPT_DIR/$SELECTED" &
