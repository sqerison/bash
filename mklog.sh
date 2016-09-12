#!/usr/bin/env bash
#set -x

#
# Examples:
# mklog hostname "3h 15min ago"
#

MYPASS="Your_Pass"
host_name="$1"
sinse_time="$2"
data_time=$(date +"%Y-%m-%d_%H-%M-%S")
service_name=$(/usr/bin/ssh -o LogLevel=quiet -t -t ec2-user@spark "ssh $host_name 'ls *.service'" | rev | cut -c 2- | rev)
log_name="`echo $service_name | rev | cut -c 9- | rev`-service-$data_time.log"
#exit 0

cd ~
/usr/bin/ssh -o LogLevel=quiet -t -t ec2-user@spark "ssh $host_name \"journalctl -r -u  $service_name --since '$sinse_time' | gzip -c > $log_name.gz\""
ssh ec2-user@spark "scp $host_name:$log_name.gz ~/logs/"
scp ec2-user@spark:~/logs/$log_name.gz ~ &>/dev/null
#ssh ec2-user@spark "rm $log_name.gz"
curl -X PUT -u sqerison:$MYPASS "http://172.23.99.26:88/remote.php/webdav/Logs/$log_name.gz" --data-binary @"$log_name.gz"
rm $log_name.gz
echo "http://172.23.99.26:88/remote.php/webdav/Logs/$log_name.gz"
cd - &>/dev/null
exit 0
