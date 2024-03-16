#!/bin/bash

# Update package index
sudo apt update

# Install OpenVPN
sudo apt install -y openvpn

# Copy sample configuration file
sudo cp /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz /etc/openvpn/

# Unzip sample configuration file
sudo gzip -d /etc/openvpn/server.conf.gz

# Enable IP forwarding
sudo sysctl -w net.ipv4.ip_forward=1
sudo sysctl -p

# Install Easy-RSA
sudo apt install -y easy-rsa

# Copy Easy-RSA scripts
sudo cp -r /usr/share/easy-rsa/ /etc/openvpn/

# Initialize Easy-RSA PKI
sudo /etc/openvpn/easy-rsa/easyrsa init-pki

# Build the CA
sudo /etc/openvpn/easy-rsa/easyrsa build-ca

# Generate server key and certificate
sudo /etc/openvpn/easy-rsa/easyrsa gen-req server nopass
sudo /etc/openvpn/easy-rsa/easyrsa sign-req server server

# Generate Diffie-Hellman parameters
sudo /etc/openvpn/easy-rsa/easyrsa gen-dh

# Generate HMAC signature
openvpn --genkey --secret /etc/openvpn/ta.key

# Restart OpenVPN service
sudo systemctl restart openvpn
