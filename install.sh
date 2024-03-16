

#!/bin/bash

# URLs of the files to download
FILES=(
    "https://raw.githubusercontent.com/egarim/OpenVpnUbuntu/main/setup_openvpn_server.sh"
    "https://raw.githubusercontent.com/egarim/OpenVpnUbuntu/main/generate_ovpn.sh"
    "https://raw.githubusercontent.com/egarim/OpenVpnUbuntu/main/copy_to_www.sh"
)

# Download and overwrite files
for FILE_URL in "${FILES[@]}"; do
    FILE_NAME=$(basename "$FILE_URL")
    echo "Downloading $FILE_NAME..."
    wget -q --show-progress -N "$FILE_URL"
done

# Change permissions to executable
for FILE_URL in "${FILES[@]}"; do
    FILE_NAME=$(basename "$FILE_URL")
    echo "Changing permissions for $FILE_NAME..."
    chmod +x "$FILE_NAME"
done

echo "All files downloaded and permissions changed successfully."
