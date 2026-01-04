#!/bin/bash

# Renames image files such that they are shifted down the Y axis by the
# given amount.
#
# Given that image files are in an img subdirectory.
# Filenames of these image files is y_x.png. For example: 1_4.png 2_3.png
# X and Y axes are 1 to 15.
#
# For example:
#   shiftdown.sh 3
#   1_4.png becomes 4_4.png
#   12_3.png becomes 15_3.png
#
# Usage:
#   shiftdown.sh [shift]
#   shift = integer to add to the Y coordinate

set -euo pipefail

if [[ -z ${1-} ]]; then
	cat <<EOF
Usage: $0 shift

Renames files in the ./img subdirectory named Y_X.ext by adding \`shift\` to the Y coordinate.

Example:
	$0 3  # shift by 3
EOF
	exit 1
fi

shift_by=$1

if ! [[ $shift_by =~ ^-?[0-9]+$ ]]; then
	echo "shift must be an integer" >&2
	exit 2
fi

# Move from high to low to avoid overwriting files we still need to move.
for (( y = 15 - shift_by; y >= 1; y-- )); do
	for (( x = 15; x >= 1; x-- )); do
		src="imgs/${y}_${x}.png"
		dst="imgs/$(( y + shift_by ))_${x}.png"
		if [[ -e "$src" ]]; then
			mv -- "$src" "$dst"
		fi
	done
done
