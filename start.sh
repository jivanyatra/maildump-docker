#!/bin/sh

# expecting incoming command like:
# maildump -f --smtp-port 1025 --http-port 1080 --db /data/maildump.db --http-ip 0.0.0.0 --smtp-ip 0.0.0.0
# it MUST listen on 0.0.0.0 or some other IP for things to work
# it doesn't work with the default 127.0.0.1

# DBFILE
cd /app
ls -al
WITHDB="maildump -f -n --smtp-ip 0.0.0.0 --http-ip 0.0.0.0 --smtp-port 1025 --http-port 1080 --db /data/maildump.db"
SANSDB="maildump -f -n --smtp-ip 0.0.0.0 --http-ip 0.0.0.0 --smtp-port 1025 --http-port 1080"
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
