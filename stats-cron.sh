#!/bin/bash
#set -x
path_to_files=~/files
path_to_archive=~/archives
disc_path=/dev/xvda1

function daily() {
	folders_to_archive=$(cd $path_to_files; find -type d -mtime +5 | cut -d / -f2)
	for folder in $folders_to_archive; do 
		tar -zcvf $path_to_archive/files-$folder.tar.gz -C $path_to_files $folder
		# --remove-files
	done
}

function space() {
	disc_usage=$(df -h $disc_path | awk 'NR==2 {print $5}' | sed 's/%//')
	if   [ "$disc_usage" -ge 75 ]; then
		find $path_to_archive -mtime +15 -exec ls {} \;
	else
		echo "OK: $disc_path - $disc_usage%"
	fi
}

if   [ "$1" == daily ]; then
	daily
elif [ "$1" == space ]; then
	space
else
	echo "{ daily | space }"
fi