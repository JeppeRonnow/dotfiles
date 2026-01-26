#!/bin/bash

if [ $# -eq 0 ]; then
  echo "Usage: $0 --title | --arturl | --artist | --length | --album | --source | --status"
  exit 1
fi

# Function to get metadata using playerctl
get_metadata() {
  key=$1
  playerctl metadata --format "{{ $key }}" 2>/dev/null
}

# Function to determine the source and return an icon and text
get_source_info() {
  player=$(playerctl metadata --format "{{ playerName }}" 2>/dev/null)
  case "$player" in
  firefox | zen)
    echo -e "󰻃 Zen Browser"
    ;;
  spotify)
    echo -e " Spotify"
    ;;
  chromium | google-chrome)
    echo -e " Chrome"
    ;;
  *)
    echo "$player"
    ;;
  esac
}

# Get album art URL and handle different formats
get_arturl() {
  url=$(get_metadata "mpris:artUrl")

  if [ -z "$url" ]; then
    echo ""
    return
  fi

  # Handle file:// URLs
  if [[ "$url" == file://* ]]; then
    url=${url#file://}
    # Decode URL encoding
    url=$(echo -e "$(echo "$url" | sed 's/+/ /g;s/%/\\x/g')")
  fi

  # Handle HTTP URLs (for Spotify, YouTube, etc.)
  if [[ "$url" == http://* ]] || [[ "$url" == https://* ]]; then
    # Download image to cache and return local path
    cache_dir="$HOME/.cache/hyprlock-media"
    mkdir -p "$cache_dir"

    # Create a hash of the URL for consistent caching
    url_hash=$(echo -n "$url" | md5sum | cut -d' ' -f1)
    cache_file="$cache_dir/$url_hash.jpg"

    # Download if not cached
    if [ ! -f "$cache_file" ]; then
      curl -s -L "$url" -o "$cache_file" 2>/dev/null || echo ""
    fi

    [ -f "$cache_file" ] && echo "$cache_file" || echo ""
  else
    echo "$url"
  fi
}

# Parse the argument
case "$1" in
--title)
  title=$(get_metadata "xesam:title")
  if [ -z "$title" ]; then
    echo ""
  else
    echo "${title:0:28}"
  fi
  ;;
--arturl)
  get_arturl
  ;;
--artist)
  artist=$(get_metadata "xesam:artist")
  if [ -z "$artist" ]; then
    echo ""
  else
    echo "${artist:0:30}"
  fi
  ;;
--length)
  length=$(get_metadata "mpris:length")
  position=$(playerctl position 2>/dev/null)

  if [ -z "$length" ] || [ -z "$position" ]; then
    echo ""
  else
    # Konverter længde fra mikrosekunder til sekunder
    total_sec=$((length / 1000000))

    # Fjern decimaler fra position (playerctl returnerer ofte float)
    pos_sec=${position%.*}

    # Formatér position
    pos_min=$((pos_sec / 60))
    pos_s=$((pos_sec % 60))

    # Formatér længde
    total_min=$((total_sec / 60))
    total_s=$((total_sec % 60))

    printf "%02d:%02d/%02d:%02d\n" \
      "$pos_min" "$pos_s" "$total_min" "$total_s"
  fi
  ;;
--status)
  status=$(playerctl status 2>/dev/null)
  if [[ $status == "Playing" ]]; then
    echo "󰎆"
  elif [[ $status == "Paused" ]]; then
    echo "󱑽"
  else
    echo ""
  fi
  ;;
--album)
  album=$(playerctl metadata --format "{{ xesam:album }}" 2>/dev/null)
  if [[ -n $album ]]; then
    echo "$album"
  else
    echo ""
  fi
  ;;
--source)
  get_source_info
  ;;
*)
  echo "Invalid option: $1"
  echo "Usage: $0 --title | --arturl | --artist | --length | --album | --source | --status"
  exit 1
  ;;
esac
