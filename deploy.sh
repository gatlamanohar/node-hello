#!/bin/bash

# Variables passed from Terraform
EMAIL=$1
DOMAIN=$2
SERVER=$3

# Install necessary packages
sudo apt update
sudo apt install -y nginx certbot python3-certbot-nginx
sudo apt install -y curl
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

