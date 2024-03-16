#!/bin/bash

# Update package index
sudo apt update

# Install Apache
sudo apt install -y apache2

# Check Apache status
sudo systemctl status apache2

# Enable Apache to start on boot
sudo systemctl enable apache2
