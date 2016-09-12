#!/usr/bin/env bash
##############################
#
#  ***WARNING - STILL IN BETA ***
#
#  Description: Script for connecting through several jump hosts
#
#  *** VERSION: 0.9
#
#  Created:                 17/03/2016 - Volodymyr Shynkar
#  Last Modified:           05/04/2016 - Volodymyr Shynkar
#
#  Changelog:
#  ----------------
#   0.1 -   Created scripts for connect to second jump host if first fail
#   0.2 -   Added several conditions
#   0.3 -   Added hep page and case function
#   0.4 -   Reformated with while loop (better working). Added list of hosts avaliavle at ~/.ssh/config file
#   0.5 -   Added parse through first two hostname letters and print suggestion
#   0.6 -   Added colorful results
#   0.7 -   Added check for print pref hosts if there some hosts was found. Fix delay when connection was too long.
#   0.8 -   Create new function "ssh-agent" for session. More safest way when poor connection.
#   0.9 -   Close session if session was interrupted by "Ctrl+C"
#
#  Requirement:
#  ----------------
#   ssh-agent - should be configured with privat key and key forwarding
#   ~/.ssh/config - jump hosts should be defined should be defined
#
#   Example of usage:
#   ---------------
#   ./s second_hostname command_to_run (e.g - ./s my.goldhost.com df -h)
#
##############################

#set -x
#set -e
# Variables

red=$(tput setf 4)
green=$(tput setf 2)
reset=$(tput sgr0)
toend=$(tput hpa $(tput cols))$(tput cub 6)

ssh_hostname=$1
ssh_hosts="host1 host2 host3"
ssh_username=username
ssh_opt="/usr/bin/ssh -o ForwardAgent=yes -o StrictHostKeyChecking=no -o LogLevel=quiet"
activate_agent="YES"
ssh_key_path="/home/your_user_name/.ssh/id_rsa"

# Help page
ME=`basename $0`
function print_help() {
    echo -e "${green}
    Second host connecting through several jump hosts

    Parameters:
    - to print this page use '-h' or '-help' option
    - to print list of avaliable hosts use '-l' or '-list' option

    Usage: $ME options...
    You have to enter parameters in to the following way
    $ME second_hostname command_to_run\n${reset}"
    exit 2
}

# Close session if session was interrupted by "Ctrl+C"
function ctrl_c() {
        echo -e "${red}\nKeyboard Interrupt${reset}"
        exit 1
}
trap ctrl_c INT

# Create new ssh-agent for session. More safest way when poor connection.
function ssh_agent() {
	if [ "$activate_agent" == YES ]; then
		agent=$(ssh-agent)
		eval $agent &>/dev/null
		agentPid=$(echo $agent | awk '{print $NF}' | sed 's/;//')
		ssh-add "$ssh_key_path" &>/dev/null
	fi
}

# Printing list of avaliable hosts if entered wrong hostname or entered -l|-list option
function print_hosts() {
	avaliable_hosts=$(
		for hosts in $ssh_hosts
			do echo -e "\nAvaliable hosts at $hosts\n";\
			$ssh_opt -A $ssh_username@$hosts "cat ~/.ssh/config | grep '^Host'" | awk '{print$2}'
		done
		kill -15 $agentPid
	)
	echo "$avaliable_hosts"
}

# Printing help page if there no arguments
if [ $# = 0 ]; then
    print_help
fi

# Options list
while getopts "lh" opt ;
do
	case $opt in
	h|help)
		print_help
		exit 2
	;;
	l|list)
		ssh_agent
		print_hosts
		exit 0
	;;
	*) echo -ne "${red}Wrong parameter${reset}";
		echo "For help, please run: $ME with -h or -help parameter";
		exit 1
	;;
	esac
done

# Main
ssh_agent
for hosts in $ssh_hosts
	do ssh -A $ssh_username@$hosts ssh -o ConnectTimeout=3 $ssh_hostname exit &>/dev/null;
	RESULT=$?
	if [ $RESULT -eq 0 ]; then
		printf "${green}Using $hosts\n${reset}"
		$ssh_opt -t -t -A $ssh_username@$hosts "$ssh_opt -t -t $@"
		kill -15 $agentPid &>/dev/null
		exit 0
	fi
done
	if [ $RESULT -ne 0 ]; then
		printf "${red}No hostname called - $ssh_hostname were found. Please, chech the hostname or username and try again.\n${reset}"
		pref_hosts=$(print_hosts | grep ^`echo $ssh_hostname | cut -c -2`);
		# Print pref hosts if there some hosts was found
		RESULT=$?
		if [ $RESULT -eq 0 ]; then
			echo -e "\nPerhaps, you are looking for one from this hosts:\n\n$pref_hosts\n"
		fi
		exit 1
	fi

exit 0
# end
