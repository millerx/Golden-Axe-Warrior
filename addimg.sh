#!/bin/bash

coords="$1"
if [ -z "$coords" ]; then
  echo "Usage: sh addimg.sh <coords>"
  exit 1
fi

# Rename first G*.png to input.png
first_file=$(ls G*.png 2>/dev/null | head -n 1)
if [ -z "$first_file" ]; then
  echo "No G*.png file found."
  exit 1
fi

mv "$first_file" input.png

# Crop, resize, and process image
magick input.png -crop 2048x1280+0+0 +repage -resize 256x160 -interpolate bilinear -filter point output.png

# Move output to target directory
mv output.png ~/Documents/GAW/imgs/"$coords".png
