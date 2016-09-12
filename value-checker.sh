#!/bin/bash
#set -x
pre_url=http://www.skagen.com/us/en/men/watches/leather/ancher-leather-watch-pdpskw6297p.html
url=${3:-$pre_url}
target=${2:-"product-price "}
email="your_gmail@gmail.com"
first_fs="$"
second_fs="."
expected=${1:-165}
result=$(curl -s "$url" | grep "$target" | awk -F $first_fs '{print $2}' | awk -F $second_fs '{print $1}')

if [ "$result" -eq "$expected" ]; then
	echo "Value hasn't been changed"
	alert="no"
elif
	[ "$result" -gt "$expected" ]; then
	echo "Value is greater than expected! Now - $result"
	alert="no"
elif
	[ "$result" -lt "$expected" ]; then
	echo "Value is less than expected! Now - $result"
	alert="yes"
else
	echo "Nothing found, please check the URL, target or expected value"
	alert="alert"
fi

if [ "$alert" == "yes" ]; then
	echo "Sendeing Email"
	curl -s --user 'api:key-3ax6xnjp29jd6fds4gc373sgvjxteol0' \
	https://api.mailgun.net/v3/samples.mailgun.org/messages \
	-F from='Value-Ckecker <excited@samples.mailgun.org>' \
	-F to="$email" \
	-F subject='Value-Ckecker' \
	-F text="$(echo;echo You receive this mail because Value at your checker has been changed at this page:;echo;echo $url)" \
	-F text="$(echo;echo Current value is - $result;echo)" \
	-F text="Please check out what is going on there." >> /dev/null
elif [ "$alert" == "alert" ]; then
	echo "Sendeing Email"
	curl -s --user 'api:key-3ax6xnjp29jd6fds4gc373sgvjxteol0' \
	https://api.mailgun.net/v3/samples.mailgun.org/messages \
	-F from='Value-Ckecker <excited@samples.mailgun.org>' \
	-F to="$email" \
	-F subject='Value-Ckecker' \
	-F text="$(echo;echo You receive this mail because Value at your checker hasn\'t fount at this page:;echo;echo $url)" \
	-F text="Please check out what is going on there." >> /dev/null
fi
