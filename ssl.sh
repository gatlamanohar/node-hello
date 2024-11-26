#!/bin/bash

# Variables passed from Terraform
EMAIL=$1
DOMAIN=$2
SERVER=$3

# Generate Nginx configuration dynamically
cat <<EOF | sudo tee /etc/nginx/sites-available/$DOMAIN
server {
    server_name $DOMAIN;

    location / {
        proxy_pass http://$SERVER;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# Enable the site
sudo ln -s /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

# Run Certbot to obtain and install the certificate
sudo certbot --nginx --redirect --agree-tos --email "$EMAIL" -d "$DOMAIN"

# Reload Nginx to apply the changes
sudo systemctl reload nginx
