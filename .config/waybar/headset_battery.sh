#!/bin/bash

# Check if headsetcontrol is installed
if ! command -v headsetcontrol &> /dev/null; then
    echo '{"text": "N/A", "tooltip": "headsetcontrol not installed"}'
    exit 0
fi

# Get battery level with a timeout to prevent hanging
battery_output=$(timeout 5s headsetcontrol -b 2>&1)
exit_code=$?

# Check for timeout
if [ $exit_code -eq 124 ]; then
    echo '{"text": "N/A", "tooltip": "Headset query timed out"}'
    exit 0
fi

# Check if headset is connected
if echo "$battery_output" | grep -qi "Failed to find device\|No device found\|Error"; then
    echo '{"text": "N/A", "tooltip": "No headset connected"}'
    exit 0
fi

# Extract battery percentage
battery=$(echo "$battery_output" | grep -i "Level:" | grep -oP '\d+(?=%)')

# If battery is empty or 0, try to get it from alternate pattern
if [ -z "$battery" ] || [ "$battery" -eq 0 ] 2>/dev/null; then
    # Try alternate extraction pattern
    battery=$(echo "$battery_output" | grep -oP '\d+(?=%)' | head -1)
fi

# Final validation
if [ -z "$battery" ] || [ "$battery" -eq 0 ] 2>/dev/null; then
    echo '{"text": "N/A", "tooltip": "Battery info unavailable"}'
    exit 0
fi

# Output JSON for Waybar
echo "{\"text\": \"$battery\", \"tooltip\": \"HyperX Cloud Alpha Wireless: $battery%\"}"
