#!/bin/sh

# Decrypt the file
mkdir $HOME/secrets
openssl enc -d -base64 -in ${{ secrets.GCP_SECRET }} -out $HOME/secrets/gcp_cred.json
