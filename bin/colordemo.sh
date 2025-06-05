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
	for j in {30..37}; do
		printf '\e[40;%dm %3d \e[97;%dm %3d ' $((i + j)) $((i + j)) $((i + j + 10)) $((i + j + 10))
	done
  echo -e '\e[0m'
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
	(( (i < 16 && ! (i % 8)) || (i >= 16 && ! ((i - 16) % 6)) )) && echo -e '\e[m'
	printf '\e[38;5;%d;48;5;16m %3d \e[38;5;15;48;5;%dm %3d ' $i $i $i $i
done
echo -e '\e[0m'

