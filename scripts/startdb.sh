#!/bin/bash

# This script first tries to establish the database name (DBNAME). Therefor it searches for a .db file.
# if not it search for a .df file. If none of these are found, the script exits.
# 
# If a database is not present:
#     based on the .df (& .st) it builds an empty db based on those definitions.
#     The .df is hashed and the hash is written in /app/db/<dbname>.schema.hash
# 
# If database exists, it is checked in /app/schema if there's a <dbname>.df present. If so, this
# .df file is hashed and that hash is compared to the hash in <dbname>.schema.hash
#
# If these hashes are not the same, an empty database is created with the schema in /app/schema and
# a delta.df is created and applied. A new /app/db/<dbname>.schema.hash is generated.
#

function startServer() {
    proserve /app/db/$DBNAME -pf /app/db/db.pf
    echo "database started..."
    ps -ef
}

function stopServer() {
    echo "attempt to bring down $DBNAME gracefully"
    if [ -f "/app/db/$DBNAME.lk" ]; then
        echo ".lk found; execute proshut"
        proshut /app/db/$DBNAME -by
        echo "database stopped..."
    fi
    exit 0
}

function getDbname() {
    dbname=`find . -type f -name "*.db"`
    if [[ -z $dbname ]]; then 
        dbname=`find . -type f -name "*.df"`
    fi

    if [[ -z $dbname ]]; then 
        exit 1
    fi

    dbname=`basename "$dbname"`
    dbname=`echo "$dbname" | cut -d'.' -f1`

    echo $dbname
}

function initDb() {

    if [[ -f $DBNAME.lk ]]; then
        echo $DBNAME.lk found, exiting...
        exit 1
    fi

    if [[ ! -f $DBNAME.db ]]; then 
        if [[ -f $DBNAME.df ]] && [[ -f $DBNAME.st ]] ; then 
          echo "db not found, create one" >> dbstart.log
          $DLC/ant/bin/ant -f /app/scripts/database-tasks.xml -lib $DLC/pct/PCT.jar -DDBNAME=${DBNAME} createdb
          /app/scripts/hash.sh $DBNAME.df > ${DBNAME}.schema.hash
        else
            echo database \"${DBNAME}\" not found, no df for building db found
            exit 1
        fi
    else
        # db exists, check for updates
        echo DB ${DBNAME} exist, checking df diffs
        if [[ -f ${DEFDIR}/${DBNAME}.df ]]; then 
        
            newdf=$($HASH ${DEFDIR}/${DBNAME}.df)
            curdf=$(cat ${DBNAME}.schema.hash)
            echo new sha\: ${newdf}
            echo cur sha\: ${curdf}

            if [[ ${newdf} != ${curdf} ]]; then 
                echo db needs updating...
                # this part needs to go to the update-schema.sh script 
                /app/scripts/update-schema.sh ${DBNAME}
            fi
        else
            echo ${DEFDIR}/${DBNAME}.df not found
        fi

    fi
}

HASH=/app/scripts/create-hash.sh
DEFDIR=/app/schema

if [[ ${DBNAME} == "" ]]; then 
    DBNAME=$(getDbname)
fi

initDb

trap "stopServer" SIGINT SIGTERM

startServer

pidfile=/app/db/$DBNAME.lk

sleep 2

# make sure the logs are visible
tail -f /app/db/$DBNAME.lg &

# Loop while the pidfile and the process exist
# while [ -f $pidfile ] && [ ps -p $PID >/dev/null ] ; do
while [ -f $pidfile ] ; do
    sleep 0.5
done

exit 1
