#!/bin/bash
. /path/to/functions.sh
set -e

CERT_DIR=/data/letsencrypt
WORK_DIR=/data/workdir
CONFIG_PATH=/data/options.json

# Let's encrypt Deets
LE_TERMS=$(jq --raw-output '.lets_encrypt.accept_terms' $CONFIG_PATH)
LE_DOMAINS=$(jq --raw-output '.domains[]' $CONFIG_PATH)
LE_UPDATE="0"

#DNSomatic Deets
DOMUSER=$(jq --raw-output '.domuser' $CONFIG_PATH)
DOMPASS=$(jq --raw-output '.dompass' $CONFIG_PATH)
DOMHOST=$(jq --raw-output '.domhost' $CONFIG_PATH)
DOMAINS=$(jq --raw-output '.domains | join(",")' $CONFIG_PATH)
WAIT_TIME=$(jq --raw-output '.seconds' $CONFIG_PATH)

# Function that performs a renew
function le_renew() {
    local domain_args=()

    # Prepare domain for Let's Encrypt
    for domain in $LE_DOMAINS; do
        domain_args+=("--domain" "$domain")
    done

    dehydrated --cron --hook ./hooks.sh --challenge dns-01 "${domain_args[@]}" --out "$CERT_DIR" --config "$WORK_DIR/config" || true
    LE_UPDATE="$(date +%s)"
}

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

# Run DNS-O-Matic
while true; do
    answer="$(curl -s -m 60 -u $DOMUSER:$DOMPASS "https://updates.dnsomatic.com/nic/update?hostname=$DOMHOST")" || true
    echo "$(date): $answer"
    echo "DNS'o'matic updated!"

    now="$(date +%s)"
    if [ "$LE_TERMS" == "true" ] && [ $((now - LE_UPDATE)) -ge 43200 ]; then
        le_renew
    fi

    sleep "$WAIT_TIME"
done
