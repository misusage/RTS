#!/bin/bash

if [ ! $# -eq 1 ]; #if user doesn't add file argument
then
    echo "Use this script to help analyse the SNMP results from onesixtyone."
    echo "$0 snmp-results.txt"
    exit
fi

readonly color="\e[96m"
readonly reset="\e[0m"
cat $1 | awk '/\[*\]/{print $1,$2}' | sed 's/[][]//g' | sort -k2 #shows the ip addresses as well as their community string.

echo ""
echo "------------------------"
echo -e $color"  Total CommunityName"$reset
echo "------------------------"
cat $1 | awk '/\[*\]/{print $2}' | sed 's/[][]//g' | uniq -c #shows total community strings found with count.

