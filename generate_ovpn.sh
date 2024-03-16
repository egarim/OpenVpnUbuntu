#!/bin/bash

# Check if Easy-RSA exists
if [ ! -d "/etc/openvpn/easy-rsa" ]; then
    echo "Easy-RSA is not installed. Please run the server setup script first."
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
$(cat /etc/openvpn/pki/ca.crt)
</ca>
<cert>
$(sed -ne '/BEGIN CERTIFICATE/,$ p' /etc/openvpn/pki/issued/$CLIENT_NAME.crt)
</cert>
<key>
$(cat /etc/openvpn/pki/private/$CLIENT_NAME.key)
</key>
<tls-auth>
$(cat /etc/openvpn/ta.key)
</tls-auth>
<dh>
$(cat /etc/openvpn/pki/dh.pem)
</dh>
EOF

echo "Client configuration file $CLIENT_NAME.ovpn has been generated."
