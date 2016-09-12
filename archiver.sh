#!/bin/bash

set -e
LOGS_DIR=/var/log/network/
OLDER_THEN=10
NOW=$(date +"%Y-%m-%d-%H-%M-%S")

createTarArchive() {
  echo "[$(date +'%Y-%m-%d-%H-%M-%S')] Finding files older then 10 days and tar them"
  find ${LOGS_DIR} -ctime +10 | xargs tar cf logs-${NOW}.tar
  echo "[$(date +'%Y-%m-%d-%H-%M-%S')] Done"
}

createGzipArchive() {
  echo "[$(date +'%Y-%m-%d-%H-%M-%S')] Gziping logs-${NOW}.tar"
  gzip logs-${NOW}.tar
  echo "[$(date +'%Y-%m-%d-%H-%M-%S')] Done"
}

cleaningFolder() {
  echo "[$date +'%Y-%m-%d-%H-%M-%S')] Cleaning old logs"
  find ${LOGS_DIR} ! -name 'serve.py' -ctime +10 | xargs rm
  echo "[$date +'%Y-%m-%d-%H-%M-%S')] Done"
}

createTarArchive
createGzipArchive
cleaningFolder
