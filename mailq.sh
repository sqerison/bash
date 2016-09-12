#!/bin/bash
set -x
ME=`basename $0`
zero=0
reset_count=5
compare=$(($reset_count-1))
quantity=0
times=$(($quantity+1))
quontity_of_mail=$(mailq | grep "Request."| awk '{print $5}')

# Statements
if [ "$quontity_of_mail" -le "75" ]
	then
		echo "OK - $quontity_of_mail messages in queuee."
		exit 0
elif [ "$quontity_of_mail" -le "99" ]
	then
		echo "WARNING - $quontity_of_mail messages in queuee."
		echo -e "WARNING - $quontity_of_mail messages in queuee.\nPlease, check what is going on there." | mail -s "Quantity of messages at derevo.info" your_email@gmail.com
		postfix flush
		exit 1
elif [ "$quontity_of_mail" -le "500" ]
	then
		echo "CRITICAL - $quontity_of_mail messages in queuee."
		echo -e "CRITICAL - $quontity_of_mail messages in queuee.\nPlease, check what is going on there." | mail -s "Quantity of messages at derevo.info" your_email@gmail.com
		postfix flush
		# Purge queue if script was execxuted several times. From variable ${reset_count}.
		sed -i '' -e "s/quantity=0/quantity=${times}/g" /root/scripts/$ME
		if [ "$quantity" -eq "$compare" ]
			then
				echo "Quontity is $quantity. Reseting"
				sed -i '' -e "s/quantity=$reset_count/quantity=$zero/g" /root/scripts/$ME
				postsuper -d ALL
		fi
		exit 2
else
		echo "UNKNOWN - $quontity_of_mail messages in queuee."
		exit 3
fi
#done
