#!/bin/sh

# Decrypt the file
mkdir $HOME/secrets
openssl enc -d -base64 -in ./secrets/Demos-SED-ISG-IntegDemo-67fce661b7f0-pass.base64 -out ./secrets/gcp_cred.json -k "$PASSPRASE"
