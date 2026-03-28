#!/bin/bash

# Parse options: -g | --grayscale
grayscale=false
while [ "${1:-}" != "" ]; do
  case "$1" in
    -g|--grayscale)
      grayscale=true
      shift
      ;;
    -h|--help)
      echo "Usage: sh addimg.sh [-g|--grayscale] <coords>"
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
  echo "Usage: sh addimg.sh [-g|--grayscale] <coords>"
  exit 1
fi

# Parse coordinates: convert letter-based column to numeric (e.g., "9,F" -> "9,6")
row=$(echo "$coords" | cut -d, -f1)
col_letter=$(echo "$coords" | cut -d, -f2)

if [ -z "$row" ] || [ -z "$col_letter" ]; then
  echo "Invalid coordinate format. Use: row,column (e.g., 9,F)"
  exit 1
fi

# Convert letter to number (A=1, B=2, ..., O=15)
col_num=$(printf '%d' "'$col_letter")
col_num=$((col_num - 64))

if ! [[ "$col_num" =~ ^[0-9]+$ ]] || [ "$col_num" -lt 1 ] || [ "$col_num" -gt 15 ]; then
  echo "Invalid column letter: $col_letter (use A-O)"
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

# Move output to target directory with numeric filename (e.g., 9_6.png)
mv output.png ~/Documents/GAW/imgs/"${row}_${col_num}".png

# Delete the chosen screenshot since it has been processed
rm "$first_file"
