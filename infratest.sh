#!/bin/bash
for NDVAR in "vpn_client"
do
    printf "\e[1;35m Testing %s group... \e[0m \n" "$NDVAR"
    py.test --sudo --ssh-identity-file=lab02.pem --hosts="ansible://$NDVAR" "$NDVAR-test.py"
done