#!/bin/bash
#set -x
log_name=files-$(date +%d%m%Y).tar.gz
cd ~


#ssh spark "ssh -t -t stats-center tar -zcvf $log_name files/2016-06-22 files/2016-06-23; scp stats-center:$log_name ." ;\
#ssh spark "ssh -t -t stats-center tar -zcvf $log_name files/`date +%Y-%m-%d`; scp stats-center:$log_name ." ;\



ssh spark "ssh -t -t stats-center tar -zcvf $log_name files/*; scp stats-center:$log_name ." ;\
scp spark:$log_name ~/
curl  -X PUT -u sqerison:qwertyuiop -s "http://172.23.99.26:88/remote.php/webdav/Logs/$log_name" --data-binary @"$log_name" &>/dev/null
#rm ~/$log_name &>/dev/null
echo "http://172.23.99.26:88/s/bip3IgtJAIzQrwi/download?path=%2F&files=$log_name"