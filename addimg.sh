#!/bin/bash

USAGE="Usage: sh addimg.sh [-g|--grayscale] <row>,<col>"

# Parse options: -g | --grayscale
grayscale=false
while [ "${1:-}" != "" ]; do
  case "$1" in
    -g|--grayscale)
      grayscale=true
      shift
      ;;
    -h|--help)
      echo "$USAGE"
      exit 0
      ;;
    --)
      shift
      break
      ;;
    -*)
      echo "Unknown option: $1"
      exit 1
      ;;
    *)
      break
      ;;
  esac
done

coords="$1"
if [ -z "$coords" ]; then
  echo "$USAGE"
  exit 1
fi

# Parse coordinates: keep column as letter (e.g., "9,F" -> "9,F")
row=$(echo "$coords" | cut -d, -f1)
col=$(echo "$coords" | cut -d, -f2)

if [ -z "$row" ] || [ -z "$col" ]; then
  echo "Invalid coordinate format. Use: row,column (e.g., 9,F)"
  exit 1
fi

# Find the first screenshot for this ROM
first_file=$(ls Golden\ Axe\ Warrior*.png 2>/dev/null | head -n 1)
if [ -z "$first_file" ]; then
  echo "No Golden Axe Warrior*.png file found."
  exit 1
fi

# Crop, resize, and process image; add grayscale when requested
magick_args=("$first_file" -crop 2048x1280+0+0 +repage -resize 256x160 -interpolate bilinear -filter point)
if [ "$grayscale" = true ]; then
  magick_args+=(-colorspace Gray)
fi
magick "${magick_args[@]}" output.png

# Move output to target directory with letter filename (e.g., 9_F.png)
mv output.png ~/Documents/GAW/imgs/"${row}_${col}".png

# Delete the chosen screenshot since it has been processed
rm "$first_file"
