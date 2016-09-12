#!/bin/sh
sudo -S -u root  -i /bin/bash -l -c 'sync; echo 3 > /proc/sys/vm/drop_caches'
