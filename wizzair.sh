#!/bin/bash
#set -x

FROM=${1:-KTW}
TO=${2:-LWO}
DATE=${3:-2018-09-03}
ADULT=${4:-2}
RECEIVER=${5:-"YOUR_EMAIL@gmail.com"}

# Getting new fares.
RESULT_FULL=$(curl -s https://be.wizzair.com/7.12.1/Api/asset/farechart \
	-H 'user-agent: Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Mobile/15A372 Safari/604.1'\
	-H 'content-type: application/json;charset=UTF-8'\
	--data-binary '{
	  "wdc": true,
	  "flightList": [
	    {
	      "departureStation": "'$FROM'",
	      "arrivalStation": "'$TO'",
	      "date": "'$DATE'"
	    }
	  ],
	  "dayInterval": 3,
	  "adultCount": '$ADULT',
	  "childCount": 0,
	  "isRescueFare": false
	}'	--compressed)

# Get price only for future comparation
PRICE=$(echo $RESULT_FULL | jq -r '.outboundFlights[] | select(.date=="2018-09-03T00:00:00") | .price.amount')

# Get price and curency code
RESULT=$(echo $RESULT_FULL | jq -r ".outboundFlights[] | select(.date==\"${DATE}T00:00:00\") | .price | \"Price: \(.amount)\",\"Currency: \(.currencyCode)\"")

# Text template
TEXT="\
WizzAir price:
Departure: $FROM to $TO.
On date: $DATE.
For $ADULT adults.

$RESULT"

mail_alert(){
echo $TEXT
curl -s --user 'api:key-YOUR_API' \
    https://api.mailgun.net/v3/YOUR_DOMAIN/messages \
        -F from='WizzAir Chacker <postmaster@YOUR_DOMAIN>' \
        -F to="$RECEIVER" \
        -F subject='WizzAir Chacker' \
        -F text="$TEXT" &> /dev/null
}

# if we don't have a file, set old var as new
if [ ! -f "wizzair.tmp" ] ; then
	mail_alert
	echo $PRICE > wizzair-${FROM}-${TO}.tmp
	exit 0
else
	OLD_PRICE=`cat wizzair-${FROM}-${TO}.tmp`
fi

# Checking is some price changed
if [[ $PRICE -lt $OLD_PRICE ]] ; then
	mail_alert
else
	echo -e "No changes in price.\n\n$RESULT"
fi

# Save last price to file
echo $PRICE > wizzair-${FROM}-${TO}.tmp