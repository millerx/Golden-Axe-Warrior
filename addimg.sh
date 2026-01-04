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

# Rename first G*.png to input.png
first_file=$(ls G*.png 2>/dev/null | head -n 1)
if [ -z "$first_file" ]; then
  echo "No G*.png file found."
  exit 1
fi

mv "$first_file" input.png

# Crop, resize, and process image; add grayscale when requested
magick_args=(input.png -crop 2048x1280+0+0 +repage -resize 256x160 -interpolate bilinear -filter point)
if [ "$grayscale" = true ]; then
  magick_args+=(-colorspace Gray)
fi
magick "${magick_args[@]}" output.png

# Move output to target directory
mv output.png ~/Documents/GAW/imgs/"$coords".png
