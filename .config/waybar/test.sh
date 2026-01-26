#!/usr/bin/env bash

# Kør headsetcontrol og hent linjen med "Level:"
raw=$(headsetcontrol -b 2>/dev/null)
line=$(printf "%s\n" "$raw" | grep -F "Level:")

# Ekstraher tallet
level=$(printf "%s" "$line" | grep -oP 'Level:\s*\K-?\d+(?=%)')

# Hvis intet blev fundet, afslut med tom JSON
if [ -z "$level" ]; then
  echo '{"text": ""}'
  exit 0
fi

# Hvis -1 → charging
if [ "$level" = "-1" ]; then
  text="charging"
else
  text="$level"
fi

# Returnér JSON til Waybar
echo "{\"text\": \"$text\"}"
