#!/bin/bash
. functions.sh
set -e

CERT_DIR=/data/letsencrypt
WORK_DIR=/data/workdir
CONFIG_PATH=/data/options.json

# Let's encrypt Deets
LE_TERMS=$(jq --raw-output '.lets_encrypt.accept_terms' $CONFIG_PATH)
LE_DOMAINS=$(jq --raw-output '.domains[]' $CONFIG_PATH)
LE_UPDATE="0"

#CloudFlare Deets
CF_APIKEY=$(jq --raw-output '.cfapikey' $CONFIG_PATH)
CF_EMAIL=$(jq --raw-output '.cfemail' $CONFIG_PATH)

#-------
DOMAINS=$(jq --raw-output '.domains | join(",")' $CONFIG_PATH)
WAIT_TIME=$(jq --raw-output '.seconds' $CONFIG_PATH)

#Extract Zone ID for Domain
grabzoneid
#Exract A record ID
grabaid

#Grab current ip
IP=$(curl -s "https://ipinfo.io/ip")

#Create A Record or update existing with current IP
if [ -z "$AID" ]
  then
    createarecord
  else
    updateip $IP
fi

# Register/generate certificate if terms accepted
if [ "$LE_TERMS" == "true" ]; then
    # Init folder structs
    mkdir -p "$CERT_DIR"
    mkdir -p "$WORK_DIR"

    # Generate new certs
    if [ ! -d "$CERT_DIR/live" ]; then
        # Create empty dehydrated config file so that this dir will be used for storage
        touch "$WORK_DIR/config"
        dehydrated --register --accept-terms --config "$WORK_DIR/config"
    fi
fi

#Get todays date in seconds
LE_UPDATE="$(date +%s)"

# Loop: Watch for new IP and update. Renew Cert after 30 days
while true; do

    NEWIP=$(curl -s "https://ipinfo.io/ip")

    if [ "$IP" != "$NEWIP" ]; then
      updateip $NEWIP
    fi

    now="$(date +%s)"
    if [ "$LE_TERMS" == "true" ] && [ $((now - LE_UPDATE)) -ge 43200 ]; then
        LE_UPDATE="$(date +%s)"
        le_renew
    fi
    sleep "$WAIT_TIME"
done
