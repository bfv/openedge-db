#!/bin/sh
set -eu

: "${DBNAME:?DBNAME ontbreekt}"

logfile="/app/db/${DBNAME}.lg"

[ -r "$logfile" ] || exit 1

exec grep -Fq -- '(10471)' "$logfile"
