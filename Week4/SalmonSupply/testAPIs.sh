#!/bin/bash
#
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

jq --version > /dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "Please Install 'jq' https://stedolan.github.io/jq/ to execute this script"
	echo
	exit 1
fi

starttime=$(date +%s)

# Print the usage message
function printHelp () {
  echo "Usage: "
  echo "  ./testAPIs.sh -l golang|node"
  echo "    -l <language> - chaincode language (defaults to \"golang\")"
}
# Language defaults to "golang"
LANGUAGE="golang"

# Parse commandline args
while getopts "h?l:" opt; do
  case "$opt" in
    h|\?)
      printHelp
      exit 0
    ;;
    l)  LANGUAGE=$OPTARG
    ;;
  esac
done

##set chaincode path
function setChaincodePath(){
	LANGUAGE=`echo "$LANGUAGE" | tr '[:upper:]' '[:lower:]'`
	case "$LANGUAGE" in
		"golang")
		CC_SRC_PATH="github.com/example_cc/go"
		;;
		"node")
		CC_SRC_PATH="$PWD/artifacts/src/github.com/example_cc/node"
		;;
		*) printf "\n ------ Language $LANGUAGE is not supported yet ------\n"$
		exit 1
	esac
}

setChaincodePath

echo "POST request Enroll on fredrick  ..."
echo
fredrick_TOKEN=$(curl -s -X POST \
  http://localhost:4000/users \
  -H "content-type: application/x-www-form-urlencoded" \
  -d 'username=Jim&orgName=Fredrick')
echo $fredrick_TOKEN
fredrick_TOKEN=$(echo $fredrick_TOKEN | jq ".token" | sed "s/\"//g")
echo
echo "fredrick token is $fredrick_TOKEN"
echo
echo "POST request Enroll on regulator ..."
echo
regulator_TOKEN=$(curl -s -X POST \
  http://localhost:4000/users \
  -H "content-type: application/x-www-form-urlencoded" \
  -d 'username=Barry&orgName=Regulator')
echo $regulator_TOKEN
regulator_TOKEN=$(echo $regulator_TOKEN | jq ".token" | sed "s/\"//g")
echo
echo "Regulator token is $regulator_TOKEN"
echo
echo
echo "POST request Create channel  ..."
echo
curl -s -X POST \
  http://localhost:4000/channels \
  -H "authorization: Bearer $fredrick_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"channelName":"transfers",
	"channelConfigPath":"../artifacts/channel/transfers.tx"
}'
echo
echo
sleep 5
echo "POST request Join channel on fredrick"
echo
curl -s -X POST \
  http://localhost:4000/channels/transfers/peers \
  -H "authorization: Bearer $fredrick_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.fredrick.salmonsupply.com"]
}'
echo
echo

echo "POST request Join channel on regulator"
echo
curl -s -X POST \
  http://localhost:4000/channels/transfers/peers \
  -H "authorization: Bearer $regulator_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.regulator.salmonsupply.com"]
}'
echo
echo

echo "POST Install chaincode on Fredrick"
echo
curl -s -X POST \
  http://localhost:4000/chaincodes \
  -H "authorization: Bearer $fredrick_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"peer0.fredrick.salmonsupply.com\"],
	\"chaincodeName\":\"salmon\",
	\"chaincodePath\":\"$CC_SRC_PATH\",
	\"chaincodeType\": \"$LANGUAGE\",
	\"chaincodeVersion\":\"v0\"
}"
echo
echo

echo "POST Install chaincode on Regulator"
echo
curl -s -X POST \
  http://localhost:4000/chaincodes \
  -H "authorization: Bearer $regulator_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"peer0.regulator.salmonsupply.com\"],
	\"chaincodeName\":\"salmon\",
	\"chaincodePath\":\"$CC_SRC_PATH\",
	\"chaincodeType\": \"$LANGUAGE\",
	\"chaincodeVersion\":\"v0\"
}"
echo
echo

echo "POST instantiate chaincode on peer1 of Fredrick"
echo
curl -s -X POST \
  http://localhost:4000/channels/transfers/chaincodes \
  -H "authorization: Bearer $fredrick_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"chaincodeName\":\"salmon\",
	\"chaincodeVersion\":\"v0\",
	\"chaincodeType\": \"$LANGUAGE\",
	\"args\":[]
}"
echo
echo

echo "POST invoke chaincode on peers of Fredrick"
echo
TRX_ID=$(curl -s -X POST \
  http://localhost:4000/channels/transfers/chaincodes/salmon \
  -H "authorization: Bearer $fredrick_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.fredrick.salmonsupply.com"],
	"fcn":"InitLedger",
	"args":[]
}')
echo "Transacton ID is $TRX_ID"
echo
echo

echo "GET query chaincode on peer1 of Fredrick"
echo
curl -s -X GET \
  "http://localhost:4000/channels/transfers/chaincodes/salmon?peer=peer0.fredrick.salmonsupply.com&fcn=query&args=%5B%22a%22%5D" \
  -H "authorization: Bearer $fredrick_TOKEN" \
  -H "content-type: application/json"
echo
echo

echo "GET query Block by blockNumber"
echo
curl -s -X GET \
  "http://localhost:4000/channels/transfers/blocks/1?peer=peer0.fredrick.salmonsupply.com" \
  -H "authorization: Bearer $fredrick_TOKEN" \
  -H "content-type: application/json"
echo
echo

echo "GET query Transaction by TransactionID"
echo
curl -s -X GET http://localhost:4000/channels/transfers/transactions/$TRX_ID?peer=peer0.fredrick.salmonsupply.com \
  -H "authorization: Bearer $fredrick_TOKEN" \
  -H "content-type: application/json"
echo
echo

############################################################################
### TODO: What to pass to fetch the Block information
############################################################################
#echo "GET query Block by Hash"
#echo
#hash=????
#curl -s -X GET \
#  "http://localhost:4000/channels/transfers/blocks?hash=$hash&peer=peer1" \
#  -H "authorization: Bearer $fredrick_TOKEN" \
#  -H "cache-control: no-cache" \
#  -H "content-type: application/json" \
#  -H "x-access-token: $fredrick_TOKEN"
#echo
#echo

echo "GET query ChainInfo"
echo
curl -s -X GET \
  "http://localhost:4000/channels/transfers?peer=peer0.fredrick.salmonsupply.com" \
  -H "authorization: Bearer $fredrick_TOKEN" \
  -H "content-type: application/json"
echo
echo

echo "GET query Installed chaincodes"
echo
curl -s -X GET \
  "http://localhost:4000/chaincodes?peer=peer0.fredrick.salmonsupply.com" \
  -H "authorization: Bearer $fredrick_TOKEN" \
  -H "content-type: application/json"
echo
echo

echo "GET query Instantiated chaincodes"
echo
curl -s -X GET \
  "http://localhost:4000/channels/transfers/chaincodes?peer=peer0.fredrick.salmonsupply.com" \
  -H "authorization: Bearer $fredrick_TOKEN" \
  -H "content-type: application/json"
echo
echo

echo "GET query Channels"
echo
curl -s -X GET \
  "http://localhost:4000/channels?peer=peer0.fredrick.salmonsupply.com" \
  -H "authorization: Bearer $fredrick_TOKEN" \
  -H "content-type: application/json"
echo
echo


echo "Total execution time : $(($(date +%s)-starttime)) secs ..."
