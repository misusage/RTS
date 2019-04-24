#!/bin/bash
#Helps automate the enumeration of snmp community strings.

banner() {
	echo -e $green"                   __   _ "
	echo -e "  ___  _ __   ___ / /_ / |"
	echo -e " / _ \| '_ \ / _ \ '_ \| |"
	echo -e "| (_) | | | |  __/ (_) | |"
	echo -e " \___/|_| |_|\___|\___/|_|"
	echo -e "=========================="$reset
	echo -e "SNMP Enumeration Automation"
	echo -e "This script is dependent on onesixtyone. It will be installed if it does not already exist."
	echo -e "Once finished, three files will be created: 
		1. ip-list will be created with a list of all the hosts.
		2. A community file will be created will a list of all the community strings.
		3. snmp-results will be created with all the results."	
	echo -e ""
	echo -e "Credits to $lightYellow@trailofbits$reset for creating this awesome software."
	echo -e ""
} 

#the main program
main() {

	echo ""	
	read -n 1 -s -r -p "First, let's check if onesixtyone is installed (Press any key to continue):"
	echo ""
	if ! [ -x "$(command -v onesixtyone)" ]; then
		echo "Onesixtyone snmp enumerator is not installed on your box."
		read -p "Install? (y/n): " choice2
		case "$choice2" in
		[yY]|[yYeEsS] )
			echo "Installing..."
			apt-get update && apt-get -y -qq install onesixtyone
			success "Done!. onesixtyone has been installed.";;
		[nN]|[nNoO] )
			error "Exiting $0. You need the dependencies to continue."
			exit;;
		* ) 
			error "Wrong key detected."
			error "Exiting $0. You need the dependencies to continue."
			exit;;
		esac

	else
		success "Onesixtyone is installed."	
	fi

	echo ""
#-------------------------------------------
	read -n 1 -s -r -p "Next, let's start the community list file generation process (Press any key to continue): " 
	echo ""	
	#if you have internet, then download big list.
	read -p "Do you want to download the SecLists big SNMP list? (y/n): " downloadme
	case "$downloadme" in
		[yY]|[yYeEsS] )
			#go to the internet to download
			echo -e "GET http://google.com HTTP/1.0\n\n" | nc google.com 80 > /dev/null 2>&1
			if [ $? -eq 0 ]; then
				echo ""
				echo "Downloading the Big SNMP list from SecLists."
				wget https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/SNMP/snmp_onesixtyone.txt -O snmp-big-community.txt	
				success "Created SNMP Community String List: snmp-big-community.txt"
				communityfile="snmp-big-community.txt"
			else
				echo ""
				noterror "Seems you can't connect to the internet. I'll just create a small snmp community string list for you."
				create_community	
			fi
			sleep 1;;
		[nN]|[nNoO] )
			echo ""
			noterror "Seems you don't want to download the SNMP list from SecLists."
			echo ""
			echo "I'll just create a small snmp community string list for you."
			create_community;;
		* )
			echo ""
			noterror "Seems you don't want to download the SNMP list from SecLists."
			echo ""
			echo "I'll just create a small snmp community string list for you."
			create_community;;
	esac
#-------------------------------------------
	echo ""
	sleep 1
	echo "Next, let's generate a list of IPs you'll be scanning."
	hostlistexists
	read -n 1 -s -r -p "Before we continue, let me explain the process... (Press any key to continue): "
	echo -e "\n"
	echo -e $green"----------------------------------------------"$reset
	echo "Onesixtyone needs a file containing a list of IPs you want to scan. I will now help you create that file."
	echo "For this to work, you will need the IP/CIDR of all the networks you want to be included in that file."
	echo -e "This script will prompt you$lightCyan TWICE$reset, once for the$lightCyan network IP$reset, then once more for the$lightCyan CIDR block$reset."
	echo -e "It will then$lightCyan REPEAT$reset and prompt you again for the next range until you are done."
	echo ""
	echo "For example, if you want to 192.168.1.0/23 to be added to the list, then..."
	echo -e "In the$lightCyan FIRST$reset prompt, input$lightCyan 192.168.1.0$reset. In the$lightCyan SECOND$reset prompt, enter$lightCyan 23$reset."
	echo -e $green"----------------------------------------------"$reset
	read -n 1 -s -r -p "Press any key to continue..."
	echo -e "\n"

	caseme=y
	cidrnote=1
	while [[ "$caseme" = y ]]
	do
		read -p "What is the IP? (Example - 192.168.1.0): " ip
		if valid_ip $ip; 
		then
			#ip is valid so create list of IPs
			echo -e "You entered a valid ip: $lightCyan $ip $reset"
			read -p "What is the CIDR notation?: " cidrnote
			iplist $ip $cidrnote
		else
			error "The IP address you entered is incorrect. Please try again."
		fi
		
		echo ""	
		read -p "Do you want to add another IP range to the list? (y/n): " caseme
		echo ""
	done
	success "Done. Created IP List: ip-list.txt"
}

iplist() {
	#local variables
	local ip=$1
	local cidr=$2

	#creates the file if it doesn't exist
	touch ip-list.txt

	#Using nmap, create the list. This doesn't scan or do anything else. 
	#This just creates the list and removes the network & broadcast ips and extra text.
	nmap -n -sL $1/$2 | grep "Nmap scan report" | awk '{print $NF}' | sed -e '1d; $d' >> ip-list.txt
	success "Successfully added $1/$2 into the file."
}

work() {
	echo ""
	echo -e "Finally time to run onesixtyone. If for any reason the tool fails, run the following command:"
	echo -e $lightYellow"onesixtyone -c $communityfile -i ip-list.txt -o snmp-results.txt $reset"
	echo -e $lightCyan"------------------------------------------------------------------"$reset
	read -n 1 -s -r -p "Press any key to start..."
	echo -e "\n\n"
	onesixtyone -c $communityfile -i ip-list.txt -o snmp-results.txt
}

create_community() {
	#creates the community list file.
	touch snmp-small-community.txt
	echo I\$ilonpublic > snmp-small-community.txt
	echo public >> snmp-small-community.txt
	echo private >> snmp-small-community.txt
	echo internal >> snmp-small-community.txt
	echo cisco >> snmp-small-community.txt
	echo manager >> snmp-small-community.txt
	echo read >> snmp-small-community.txt
	echo admin >> snmp-small-community.txt
	echo default >> snmp-small-community.txt
	echo read-write >> snmp-small-community.txt
	echo secret >> snmp-small-community.txt
	echo snmp >> snmp-small-community.txt
	echo CISCO >> snmp-small-community.txt
	echo access >> snmp-small-community.txt
	echo pass >> snmp-small-community.txt
	echo password >> snmp-small-community.txt
	echo root >> snmp-small-community.txt
	echo security >> snmp-small-community.txt
	echo write >> snmp-small-community.txt
	echo system >> snmp-small-community.txt
	echo snmpd >> snmp-small-community.txt
	echo monitor >> snmp-small-community.txt
	echo all >> snmp-small-community.txt
	echo enable >> snmp-small-community.txt
	echo OrigEquipMfr >> snmp-small-community.txt
	echo IBM >> snmp-small-community.txt
	echo agent >> snmp-small-community.txt
	echo network >> snmp-small-community.txt
	echo mngt >> snmp-small-community.txt
	echo 4changes >> snmp-small-community.txt
	echo 2read >> snmp-small-community.txt
	echo ibm >> snmp-small-community.txt
	echo proxy >> snmp-small-community.txt
	echo apc >> snmp-small-community.txt
	echo rw >> snmp-small-community.txt
	echo Admin >> snmp-small-community.txt
	echo readwrite >> snmp-small-community.txt
	echo trap >> snmp-small-community.txt
	echo hp_admin >> snmp-small-community.txt
	echo core >> snmp-small-community.txt
	echo all private >> snmp-small-community.txt
	echo PRIVATE >> snmp-small-community.txt
	echo adm >> snmp-small-community.txt
	echo PUBLIC >> snmp-small-community.txt
	echo SWITCH >> snmp-small-community.txt
	echo superuser >> snmp-small-community.txt
	echo rwa >> snmp-small-community.txt

	success "Created SNMP Community String List: snmp-small-community.txt"
	communityfile="snmp-small-community.txt"
}

valid_ip() {
	local ip=$1
	local stat=1
	
	if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        	OIFS=$IFS		
		IFS='.'
		ip=($ip)
		IFS=$OIFS
		[[ ${ip[0]} -le 255 && ${ip[1]} -le 255 && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
		stat=$?
	fi
	return $stat
}

hostlistexists() {
#checks if the host list exists.
	if [ -f ip-list.txt ]; then
		echo -e "Existing host list found:$lightCyan ip-list.txt$reset"
		read -p "Do you want to overwrite it? (y/n): " choice		
		case "$choice" in
			[yY]|[yYeEsS] )
				error "Deleting old iplist.txt file."
				echo ""
				echo "" > ip-list.txt;;
			[nN]|[nNoO] ) 
				success "Keeping current iplist.txt file."
				echo ""
				touch ip-list.txt;;
			* )		
				success "Keeping current iplist.txt file."
				echo ""
				touch ip-list.txt;;
		esac
	fi
}

msg() {
   	printf '%b\n' "$1" >&2
}

success() {
   	msg "\33[32m[✔]\33[0m ${1}${2}"
}

error() {
   	msg "\33[31m[✘]\33[0m ${1}${2}"
}

noterror() {
   	msg "\33[33m[-]\33[0m ${1}${2}"
}

start() {
	banner
	main
	work
}

#globals
communityfile=""
readonly reset="\e[0m"
readonly lightCyan="\e[96m"
readonly green="\e[38;5;46m"
readonly lightYellow="\e[93m"
start
                         
