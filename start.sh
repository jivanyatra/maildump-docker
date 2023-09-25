#!/bin/sh

# expecting incoming command like:
# maildump -f --smtp-port 1025 --http-port 1080 --db /data/maildump.db
# DBFILE
cd /root/.local/
ls -al
WITHDB="maildump -f -n --smtp-port 1025 --http-port 1080 --db /data/maildump.db"
SANSDB="maildump -f -n --smtp-port 1025 --http-port 1080"
if [ -n "$DBFILE" ] 
then
  if [[ "$DBFILE" == 1 ]]
  then
    $WITHDB
  else
    $SANSDB
  fi
else
  $SANSDB
fi
