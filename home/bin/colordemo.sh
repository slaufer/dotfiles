#!/bin/bash

echo "3-Bit Background Colors"
for i in `seq 0 7`; do
	echo -ne "\e[4${i}m ${i} \e[m"
done

echo -e "\n\n3-Bit Foreground Colors"
echo -n "Regular: "
for i in `seq 0 7`; do
	echo -ne "\e[3${i}m ${i} \e[m"
done
echo -ne "\nBold:    "
for i in `seq 0 7`; do
	echo -ne "\e[1;3${i}m ${i} \e[m"
done

echo -e "\n\n8-Bit Colors"
for i in `seq 0 255`; do
	echo -ne "\e[48;5;${i}m ${i} \e[m"
done
echo
