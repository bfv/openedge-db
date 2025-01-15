#!/bin/bash

get_timestamp() {
  date +"%Y%m%d-%H%M%S"
}

timestamp=$(get_timestamp)

if [[ $1 == "online" ]]; then
  probkup $1 /app/db/${DBNAME} /app/backup/${DBNAME}-${timestamp}.bk 
else
  # somehow the offline backup fails if the backup file is not touched first 
  touch /app/backup/${DBNAME}_${timestamp}.bk
  probkup /app/db/${DBNAME} /app/backup/${DBNAME}_${timestamp}.bk 
  echo "Backup completed: ${DBNAME}_${timestamp}.bk"
fi
