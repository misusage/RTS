#!/bin/bash
#EyeWitness Script.
#Scans, Creates Directory, and Done.

if [ $# -ne 3 ]; then
	echo "EyeWitness Script"
	echo "Too lazy to do everything manually? Just provide ipblock, cidr notaion, and the directory"
	echo "you'd like to save everything as. Run this from the directory you'd like to save everything in."
	echo "$0 ipblock cidr dirname" 
	echo "Example: $0 192.168.1.0 24 CorporateWebServers"
	exit
fi

PORTS=80,8080,8081,8082,8083,443,10243,5985,47001,5700,5064,6059,5071,4102,5054,5058,5065,6069

nmap -p $PORTS --open $1/$2 -oX Eye-$1cidr$2.xml
/opt/EyeWitness/EyeWitness.py -d $3 -x Eye-$1cidr$2.xml --web
