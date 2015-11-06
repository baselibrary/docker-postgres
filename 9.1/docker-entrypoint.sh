#!/bin/bash

#enable job control in script
set -e -m

#####   variables  #####  
: ${POSTGRES_USER:=postgres}
: ${POSTGRES_DATABASE:=$POSTGRES_USER}
: ${POSTGRES_PASSWORD:=$POSTGRES_USER}   
: ${POSTGRES_EXTENSIONS_POSTGIS:=false}   

# add command if needed
if [ "${1:0:1}" = '-' ]; then
  set -- postgres "$@"
fi

#run command in background
if [ "$1" = 'postgres' ]; then
  ##### pre scripts  #####
  echo "========================================================================"
  echo "initialize:"
  echo "========================================================================"
  mkdir -p $PGDATA && chown -R postgres:postgres "$PGDATA"
  if [ ! -s "$PGDATA/PG_VERSION" ]; then
    gosu postgres initdb --locale=en_US.UTF-8
    # set auth method
    /usr/bin/ansible local -o -c local -m lineinfile  -a "dest=$PGDATA/pg_hba.conf insertafter='EOF' line='host    all             all             0.0.0.0/0                md5'"
    # set listen addresses
    /usr/bin/ansible local -o -c local -m lineinfile  -a "dest=$PGDATA/postgresql.conf regexp='^#(listen_addresses\s*=\s*)\S+' line=\"listen_addresses = '*'\""
  fi
  
  ##### run scripts  #####
  echo "========================================================================"
  echo "startup:"
  echo "========================================================================"
  exec gosu postgres "$@" &
  for i in {30..0}; do
    if echo 'SELECT 1' | psql --username postgres &> /dev/null; then
      break
    fi
    echo 'PostgreSQL init process in progress...'
    sleep 1
  done
  if [ "$i" = 0 ]; then
    echo >&2 'PostgreSQL init process failed'
    exit 1
  else
    echo >&2 'PostgreSQL init process complete'
  fi

  ##### post scripts #####
  echo "========================================================================"
  echo "configure:"
  echo "========================================================================"
  if [ "$POSTGRES_DATABASE" ]; then
    /usr/bin/ansible local -o -c local -m postgresql_db  -a "name=$POSTGRES_DATABASE encoding=UTF-8"
  fi

  if [ "$POSTGRES_USER" -a "$POSTGRES_PASSWORD" ]; then
    /usr/bin/ansible local -o -c local -m postgresql_user -a "db=$POSTGRES_DATABASE name=$POSTGRES_USER password=$POSTGRES_PASSWORD"
  fi

  if [ "$POSTGRES_EXTENSIONS_POSTGIS" ]; then
    /usr/bin/ansible local -o -c local -m postgresql_ext -a "db=$POSTGRES_DATABASE name=hstore"
    /usr/bin/ansible local -o -c local -m postgresql_ext -a "db=$POSTGRES_DATABASE name=postgis"
    /usr/bin/ansible local -o -c local -m postgresql_ext -a "db=$POSTGRES_DATABASE name=postgis_topology"
  fi
  
  #bring command to foreground
  fg
else
  exec "$@"
fi
