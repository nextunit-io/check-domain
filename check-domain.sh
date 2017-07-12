#!/bin/bash

DOMAINS=();
AVAILABLE_DOMAINS=();
EMAIL="";

function _usage() {
  echo "Usage: $0 -d domain1.tld [-d domain2.tld ...] [-m email]"
}

function _getOpts {
  local OPTIND
  while getopts ":d:m:" opt; do
    case $opt in
      d)
        DOMAINS+=($OPTARG)
        ;;
      m)
        EMAIL=$OPTARG
        ;;
      :)
        echo "Option -$OPTARG requires an argument." >&2
        exit 1
        ;;
      ?)
        _usage
        exit 1
        ;;
    esac
  done
  shift $((OPTIND -1))
}

function _validate() {
  if [ "0" -eq "${#DOMAINS[@]}" ]; then
    echo "No domains selected."
    exit 1
  fi
}

function _domainLookup() {
  EMAIL_COUNT=$(whois $1 | grep Email | wc -l)
  if [ "0" -eq "$EMAIL_COUNT" ]; then
    echo "Domain $1 is available";
    AVAILABLE_DOMAINS+=($1);
  else
    echo "Domain $1 is not available";
  fi
}

function _sendMail() {
  if [ "0" -ne "${#AVAILABLE_DOMAINS[@]}" ] && [ -n "$EMAIL" ]; then
    AVAILABLE_DOMAINS_STRING="";
    for d in ${AVAILABLE_DOMAINS[@]}; do
      if [ -n "$AVAILABLE_DOMAIN_STRING" ]; then
        AVAILABLE_DOMAIN_STRING="$AVAILABLE_DOMAIN_STRING,"
      fi

      AVAILABLE_DOMAIN_STRING="${AVAILABLE_DOMAIN_STRING}$d"
    done
    
    export REPLYTO=domainlookup@nextunit.io
    echo "This domains are currently available: $AVAILABLE_DOMAIN_STRING" | mail -aFrom:domainlookup@nextunit.io -s "Domains available" $EMAIL
  fi
}

_getOpts $*
_validate

for d in ${DOMAINS[@]}; do
        _domainLookup $d
done

_sendMail

echo "Done."
