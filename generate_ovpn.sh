#!/bin/bash

# Set Easy-RSA and OpenVPN directories
EASY_RSA_DIR="/etc/openvpn/easy-rsa"
OVPN_DIR="/etc/openvpn"

# Check if Easy-RSA and OpenVPN directories exist
if [ ! -d "$EASY_RSA_DIR" ] || [ ! -d "$OVPN_DIR" ]; then
    echo "Error: Easy-RSA or OpenVPN directory not found. Please make sure OpenVPN is installed and configured."
    exit 1
fi

# Check if client name is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <client_name>"
    exit 1
fi

# Set client name
CLIENT_NAME="$1"

# Set Easy-RSA directory
cd "$EASY_RSA_DIR" || exit

# Generate client key and certificate
./easyrsa gen-req "$CLIENT_NAME" nopass
./easyrsa sign-req client "$CLIENT_NAME"

# Determine server's public IP address
SERVER_IP=$(curl -s ifconfig.me)

# Determine OpenVPN port
OVPN_PORT=$(grep -w "^port" "$OVPN_DIR/server.conf" | awk '{print $2}')

# Create client configuration file
cat << EOF > "$CLIENT_NAME.ovpn"
client
dev tun
proto udp
remote $SERVER_IP $OVPN_PORT
resolv-retry infinite
nobind
persist-key
persist-tun
key-direction 1
remote-cert-tls server
cipher AES-256-CBC
auth SHA256
verb 3
<ca>
$(cat "$OVPN_DIR/pki/ca.crt")
</ca>
<cert>
$(sed -ne '/BEGIN CERTIFICATE/,$ p' "$OVPN_DIR/pki/issued/$CLIENT_NAME.crt")
</cert>
<key>
$(cat "$OVPN_DIR/pki/private/$CLIENT_NAME.key")
</key>
<tls-auth>
$(cat "$OVPN_DIR/ta.key")
</tls-auth>
<dh>
$(cat "$OVPN_DIR/dh.pem")
</dh>
EOF

echo "Client configuration file $CLIENT_NAME.ovpn and certificates have been generated."
