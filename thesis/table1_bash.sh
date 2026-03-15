#!/bin/bash
# Imperative (non-idempotent): Ensure app config exists

mkdir -p ./myapp
echo "debug=false" > ./myapp/config.ini
echo "port=8080" >> ./myapp/config.ini
chown appuser:appuser ./myapp/config.ini
chmod 644 ./myapp/config.ini