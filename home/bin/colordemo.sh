#!/bin/bash
echo
echo '#################################'
echo '### 16 color escape sequences ###'
echo '#################################'
echo
echo ' ESCAPE SEQUENCES: (replace # with color number)'
echo ' Foreground: \e[#m (use color number as displayed)'
echo ' Background: \e[#m (add 10 to color number for background)'
echo ' Both: \e[#;#m'
echo ' NOTE: color 0 is RESET -- returns all colors to terminal defaults'
echo
for i in 0 60; do
	echo
	for j in {30..37}; do
		printf '\e[40;%dm %3d \e[97;%dm %3d ' $((i + j)) $((i + j)) $((i + j + 10)) $((i + j + 10))
	done
done
echo -e '\e[0m'

echo
echo '#####################################'
echo '### 88/256 color escape sequences ###'
echo '#####################################'
echo
echo ' ESCAPE SEQUENCES: (replace # with color number)'
echo ' Foreground: \e[38;5;#m'
echo ' Background: \e[48;5;#m'
echo ' Both:       \e[38;5;#;48;5;#m'
echo
for i in {0..255}; do
	(( (i < 16 && ! (i % 8)) || (i >= 16 && ! ((i - 16) % 6)) )) && echo
	printf '\e[38;5;%d;48;5;16m %3d \e[38;5;15;48;5;%dm %3d ' $i $i $i $i
done
echo -e '\e[0m'

# col2rgb - converts xterm-256 colors between 16 and 236 to R/G/B values (range between 0 and 5),
#           NOT upscaled to 256. Note that the actual displayed R/G/B values are not smooth, and
#           output saturation for a given value is not consistent between channels, and every term
#           has slightly different color output. tl;dr don't use this for color calibration
function col2rgb {
	(( $1 > 236 || $1 < 16 )) && return 1
	local base=$(($1 - 16))
	local blue=$(( base % 6 ))
	local green=$(( (base % 36) / 6 ))
	local red=$(( base / 36 )) 
	echo $1 = $red $green $blue
}

# rgb2col - converts RGB values between 0 and 5 to a bash color, reversing the above function
function rgb2col {
	local red=$1 green=$2 blue=$3
	echo $red $green $blue = $((16 + blue + green * 6 + red * 36))
}

echo
echo '#####################################'
echo '### 24 bit color escape sequences ###'
echo '#####################################'
echo
echo ' ESCAPE SEQUENCES: (replace R/G/B with RGB values 0-255)'
echo ' Foreground: \e[38;2;R;G;Bm'
echo ' Background: \e[48;2;R;G;Bm'
echo ' Both:       \e[38;2;R;G;B;48;2;R;G;Bm'
echo ' NOTE: Most terminals with 24 bit color support will still downsample to 256 colors.'
echo '       Not all colors in this color space are displayed.'
echo
message=",.-~=*'^\`\`^'*=~-.,_"
c=0
for i in {0..255..8}; do
	echo -ne '\e[0m '
	for j in {0..255..4}; do
		# this basically just plots red and blue along the Y and X axes, and green along the diagonal.
		# background color is RGB, foreground color is inverse RGB.
		k=$(( (i + j) / 2 ))
		printf '\e[48;2;%d;%d;%d;38;2;%d;%d;%dm%s' \
			$i $k $j $((255 - i)) $((255 - k)) $((255 - j)) \
			"${message:c%${#message}:1}"
		((c++))
	done
	echo
done
echo -e '\e[m'

