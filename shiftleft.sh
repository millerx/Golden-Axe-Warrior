#!/bin/bash

# Renames image files such that they are shifted left the X axis by the
# given amount.
#
# Given that image files are in an imgs subdirectory.
# Filenames of these image files is y_x.png. For example: 1_4.png 2_3.png
# X and Y axes are 1 to 15 in filenames. (In the UI, X coordinates display as
# letters A-O, which correspond to numeric columns 1-15.)
#
# For example:
#   shiftleft.sh 3
#   1_4.png becomes 1_1.png (UI: 1,D becomes 1,A)
#   6_15.png becomes 6_12.png (UI: 6,O becomes 6,L)
#
# Usage:
#   shiftleft.sh shift
#   shift = integer to subract from the X coordinate

set -euo pipefail

if [[ -z ${1-} ]]; then
	cat <<EOF
Usage: $0 shift

Renames files in the ./imgs subdirectory named Y_X.png by subtracting \`shift\` to the X coordinate.

Example:
	$0 3  # shift left by 3
EOF
	exit 1
fi

shift_by=$1

if ! [[ $shift_by =~ ^-?[0-9]+$ ]]; then
	echo "shift must be an integer" >&2
	exit 2
fi

for (( y = 1; y <= 15; y++ )); do
	for (( x = 1 + shift_by; x <= 15; x++ )); do
		src="imgs/${y}_${x}.png"
		dst="imgs/${y}_$(( x - shift_by )).png"
		if [[ -e "$src" ]]; then
			mv -- "$src" "$dst"
		fi
	done
done
