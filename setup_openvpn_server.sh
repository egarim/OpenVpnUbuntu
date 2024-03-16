#!/bin/bash

# Update package index
sudo apt update

# Install OpenVPN and Easy-RSA
sudo apt install -y openvpn easy-rsa

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

# Generate client key and certificate
sudo ./easyrsa gen-req client1 nopass
sudo ./easyrsa sign-req client client1

# Create client configuration file
sudo bash -c "cat > /etc/openvpn/client1.ovpn" << EOF
client
dev tun
proto udp
remote $(curl -s ifconfig.me) 1194
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
tls-auth ta.key 1
cipher AES-256-CBC
auth SHA256
key-direction 1
<key>
$(cat /etc/openvpn/easy-rsa/pki/private/client1.key)
</key>
<cert>
$(cat /etc/openvpn/easy-rsa/pki/issued/client1.crt)
</cert>
<ca>
$(cat /etc/openvpn/ca.crt)
</ca>
<tls-auth>
$(cat /etc/openvpn/ta.key)
</tls-auth>
EOF

# Enable IP forwarding
sudo sed -i '/^#.*net.ipv4.ip_forward=1$/s/^#//' /etc/sysctl.conf
sudo sysctl -p

# Start and enable OpenVPN service
sudo systemctl start openvpn


# Check Apache status
#sudo systemctl status apache2

# Display OpenVPN status
#sudo systemctl status openvpn