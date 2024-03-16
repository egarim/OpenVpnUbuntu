#!/bin/bash

# Set Easy-RSA path
EASY_RSA_DIR="/etc/openvpn/easy-rsa"

# Check if Easy-RSA exists
if [ ! -d "$EASY_RSA_DIR" ]; then
    echo "Easy-RSA is not installed in $EASY_RSA_DIR. Please specify the correct directory."
    exit 1
fi

# Check if client name, server IP, and server port are provided
if [ $# -ne 3 ]; then
    echo "Usage: $0 <client_name> <server_ip> <server_port>"
    exit 1
fi

# Set client name, server IP, and server port
CLIENT_NAME="$1"
SERVER_IP="$2"
SERVER_PORT="$3"

# Change directory to Easy-RSA
cd "$EASY_RSA_DIR" || exit

# Generate client key and certificate
./easyrsa gen-req "$CLIENT_NAME" nopass
./easyrsa sign-req client "$CLIENT_NAME"

# Set OpenVPN PKI directory
OVPN_PKI_DIR="/etc/openvpn/pki"

# Create client configuration file
cat << EOF > "$CLIENT_NAME.ovpn"
client
dev tun
proto udp
remote $SERVER_IP $SERVER_PORT
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
$(cat "$OVPN_PKI_DIR/ca.crt")
</ca>
<cert>
$(sed -ne '/BEGIN CERTIFICATE/,$ p' "$OVPN_PKI_DIR/issued/$CLIENT_NAME.crt")
</cert>
<key>
$(cat "$OVPN_PKI_DIR/private/$CLIENT_NAME.key")
</key>
<tls-auth>
$(cat "$OVPN_PKI_DIR/ta.key")
</tls-auth>
<dh>
$(cat "$OVPN_PKI_DIR/dh.pem")
</dh>
EOF

echo "Client configuration file $CLIENT_NAME.ovpn and certificates have been generated."
