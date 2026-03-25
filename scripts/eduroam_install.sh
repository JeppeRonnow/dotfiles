#!/bin/bash
# SDU eduroam installation script for iwd

echo "Installing SDU eduroam for iwd..."

# Copy CA certificate to system location
echo "Installing CA certificate..."
sudo cp sdu-radius-ca.pem /etc/ssl/certs/sdu-radius-ca.pem
sudo chmod 644 /etc/ssl/certs/sdu-radius-ca.pem

# Get credentials
echo ""
read -p "Enter your SDU username (e.g., yourname@sdu.dk): " USERNAME
read -sp "Enter your password: " PASSWORD
echo ""

# Create iwd config directory if it doesn't exist
sudo mkdir -p /var/lib/iwd

# Create eduroam config file
echo "Creating eduroam configuration..."
sudo tee /var/lib/iwd/eduroam.8021x >/dev/null <<EOF
[Security]
EAP-Method=PEAP
EAP-Identity=anonymous@sdu.dk
EAP-PEAP-Phase2-Method=MSCHAPV2
EAP-PEAP-Phase2-Identity=${USERNAME}
EAP-PEAP-Phase2-Password=${PASSWORD}

[Settings]
AutoConnect=true

# Server certificate validation
EAP-TLS-CACert=/etc/ssl/certs/sdu-radius-ca.pem
EAP-TLS-ServerDomainMask=adm01.aaa.sdu.dk
EOF

# Set correct permissions (readable only by root for security)
sudo chmod 600 /var/lib/iwd/eduroam.8021x

echo ""
echo "Installation complete!"
echo "Restarting iwd..."
sudo systemctl restart iwd

echo ""
echo "You can now connect to eduroam using impala"
echo "Your credentials are stored in /var/lib/iwd/eduroam.8021x"
