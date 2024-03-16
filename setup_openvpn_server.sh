#!/bin/bash

# Update package index
sudo apt update

# Install OpenVPN
sudo apt install -y openvpn

# Create directory for easy-rsa
sudo mkdir -p /etc/openvpn/easy-rsa

# Copy easy-rsa files
sudo cp -r /usr/share/easy-rsa/* /etc/openvpn/easy-rsa/

# Change to the easy-rsa directory
cd /etc/openvpn/easy-rsa || exit

# Initialize PKI (Public Key Infrastructure)
sudo ./easyrsa init-pki

# Build CA (Certificate Authority)
sudo ./easyrsa build-ca nopass

# Generate server key and certificate
sudo ./easyrsa gen-req server nopass
sudo ./easyrsa sign-req server server

# Generate Diffie-Hellman parameters
sudo ./easyrsa gen-dh

# Generate HMAC signature to strengthen TLS integrity
openvpn --genkey --secret /etc/openvpn/ta.key

# Copy generated files to OpenVPN directory
sudo cp pki/ca.crt pki/private/server.key pki/issued/server.crt /etc/openvpn/
sudo cp pki/dh.pem /etc/openvpn/
sudo cp /etc/openvpn/ta.key /etc/openvpn/

# Copy sample server configuration file
sudo cp /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz /etc/openvpn/
sudo gzip -d /etc/openvpn/server.conf.gz

# Configure server file for maximum security
sudo sed -i 's|;tls-auth ta.key 0|tls-auth ta.key 0|' /etc/openvpn/server.conf
sudo sed -i 's|;cipher AES-256-CBC|cipher AES-256-GCM|' /etc/openvpn/server.conf
sudo sed -i 's|;auth SHA256|auth SHA512|' /etc/openvpn/server.conf
sudo sed -i 's|;user nobody|user nobody|' /etc/openvpn/server.conf
sudo sed -i 's|;group nogroup|group nogroup|' /etc/openvpn/server.conf
sudo sed -i '/^#.*push "redirect-gateway def1 bypass-dhcp"$/s/^#//' /etc/openvpn/server.conf
sudo sed -i '/^#.*push "dhcp-option DNS 208.67.222.222"$/s/^#//' /etc/openvpn/server.conf
sudo sed -i '/^#.*push "dhcp-option DNS 208.67.220.220"$/s/^#//' /etc/openvpn/server.conf

# Enable IP forwarding
sudo sed -i '/^#.*net.ipv4.ip_forward=1$/s/^#//' /etc/sysctl.conf
sudo sysctl -p

# Start and enable OpenVPN service
sudo systemctl start openvpn
sudo systemctl enable openvpn

# Install Apache
sudo apt install -y apache2

# Enable Apache to start on boot
sudo systemctl start apache2
sudo systemctl enable apache2

# Check Apache status
sudo systemctl status apache2

# Display OpenVPN status
sudo systemctl status openvpn


