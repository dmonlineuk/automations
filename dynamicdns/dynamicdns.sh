#!/bin/bash

source .env

mydomain=$MYDOMAIN
myhostname=$MYHOST
CF_API_TOKEN=$(openssl enc -d -aes-256-cbc -pbkdf2 -iter 1000000 -in "$CF_API_FILE" -pass file:"$KEY_FILE")

myip=$(curl -s https://api.ipify.org)

# Get Zone ID
ZONE_ID=$(curl -s -X GET \
  -H "Authorization: Bearer $CF_API_TOKEN" \
  "https://api.cloudflare.com/client/v4/zones?name=$mydomain" \
  | jq -r '.result[0].id')

# Get DNS Record ID + current IP
record=$(curl -s -X GET \
  -H "Authorization: Bearer $CF_API_TOKEN" \
  "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?type=A&name=$myhostname.$mydomain")

RECORD_ID=$(echo "$record" | jq -r '.result[0].id')
CFIP=$(echo "$record" | jq -r '.result[0].content')

logger -p user.info -t dynamicdns "Current External IP is $myip, Cloudflare DNS IP is $CFIP"

if [ "$CFIP" != "$myip" ] && [ -n "$myip" ]; then
  logger -p user.info -t dynamicdns "IP has changed!! Updating on Cloudflare"
  logger -p user.info -t dynamicdns $(curl -s -X PUT \
    -H "Authorization: Bearer $CF_API_TOKEN" \
    -H "Content-Type: application/json" \
    "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
    --data "{\"type\":\"A\",\"name\":\"$myhostname\",\"content\":\"$myip\",\"ttl\":120,\"proxied\":true}")
fi

