#!/bin/bash

## Check pre-requisites
source ./test_pre_requisites.sh

## Calculate stackname
NETWORKSTACKNAME=$(echo "$STACKNAMESPACE-$STACKENV-NETWORK" | tr '[:upper:]' '[:lower:]')

## Create or update network
source ./run.sh --stackname $NETWORKSTACKNAME --template network/network.yml --parameters network/network-parameters.json