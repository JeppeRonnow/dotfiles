#!/usr/bin/env bash

output=$(headsetcontrol -b 2>/dev/null)

# Ekstraher tallet efter "Level:"
level=$(echo "$output" | grep -oP 'Level:\s*\K-?\d+(?=%)')

if [ "$level" = "-1" ]; then
  echo "charging"
else
  echo "$level"
fi
