#!/bin/bash

# Check if .ovpn file exists
if [ ! -f "$1" ]; then
    echo "Usage: $0 <client_name.ovpn>"
    exit 1
fi

# Check if Apache www folder exists
if [ ! -d "/var/www/html" ]; then
    echo "Apache www folder not found. Make sure Apache is installed and configured."
    exit 1
fi

# Copy .ovpn file to Apache www folder
sudo cp "$1" /var/www/html/

# Set appropriate permissions
sudo chmod 644 /var/www/html/$(basename "$1")

echo "Client configuration file $(basename "$1") has been copied to Apache www folder."
