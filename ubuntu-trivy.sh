#!/bin/bash

set -e

echo "🔄 Updating system..."
sudo apt update -y

echo "📦 Installing dependencies..."
sudo apt install -y wget apt-transport-https gnupg lsb-release

echo "🔑 Adding Trivy GPG key..."
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key \
| sudo gpg --dearmor -o /usr/share/keyrings/trivy.gpg

echo "📌 Adding Trivy repository..."
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" \
| sudo tee /etc/apt/sources.list.d/trivy.list

echo "📦 Installing Trivy..."
sudo apt update -y
sudo apt install -y trivy

echo "✅ Verifying installation..."
trivy --version

echo "🎉 Trivy installation completed successfully!"
