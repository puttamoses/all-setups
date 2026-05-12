#!/bin/bash

sudo apt update -y
sudo apt install -y gnupg software-properties-common curl

# Add HashiCorp GPG key
curl -fsSL https://apt.releases.hashicorp.com/gpg | \
sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Use jammy manually (Ubuntu 22.04 compatible)
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com jammy main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update -y

sudo apt install -y terraform

terraform -version
