#!/bin/bash

# Script created on 20130816 by Tom van Leeuwen
# github repo: https://github.com/TvL2386/pdns-tools
# license: The MIT License (MIT) (https://raw.github.com/TvL2386/pdns-tools/master/LICENSE)
# Please keep this information in the script

# mysql settings
PASS="secret"
USER="root"
HOST="localhost"
DB="pdns"

##################################
# Command line argument checking #
##################################
if [ "$1" == "-f" ]; then
  FORCE=0
else
  FORCE=1
  echo "Use $0 -f to really remove domains"
  echo
fi
##################################

function query() {
  echo "$1" | mysql -N -u${USER} -p${PASS} -h${HOST} ${DB}
}

function remove_domain() {
  SQL="DELETE records, domains FROM records JOIN domains ON records.domain_id = domains.id WHERE domains.name = '$1';"

  if [ $FORCE -eq 0 ]; then
    echo "Removing domain $1"
    query "${SQL}"
  else
    echo "Use force ($0 -f) to remove domain $1"
    #echo $SQL
  fi
}

# Get all SLAVE domains with a supermaster ip
sql="SELECT d.name, s.ip, s.nameserver FROM domains d INNER JOIN supermasters s ON s.ip = d.master;"
query "$sql" | while read DOMAIN SUPERMASTER NAMESERVER ; do
  echo "Testing domain ${DOMAIN}"

  # Get nameservers for DOMAIN
  OUTPUT=$(dig +tcp +short NS ${DOMAIN} @${SUPERMASTER})
  if [ $? -eq 0 ]; then
    # Command succesfully executed
    # Check if we are authorative
    echo $OUTPUT | grep -q ${NAMESERVER}
    if [ $? -eq 0 ]; then
      echo "We are authorative for ${DOMAIN}"
    else
      echo "We are not authorative for ${DOMAIN}"
      remove_domain $DOMAIN
    fi
  else
    echo "Could not query domain ${DOMAIN} on supermaster ${SUPERMASTER}"
  fi

  echo
done

