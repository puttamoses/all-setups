#!/bin/bash

# Update packages
sudo apt update -y

# Install dependencies
sudo apt install -y openjdk-11-jdk unzip wget

# Go to /opt
cd /opt

# Download SonarQube (if not already downloaded)
if [ ! -f sonarqube-8.9.6.50800.zip ]; then
  sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-8.9.6.50800.zip
fi

# Unzip (only if not already extracted)
if [ ! -d sonarqube-8.9.6.50800 ]; then
  sudo unzip sonarqube-8.9.6.50800.zip
fi

# Create sonar user with home directory
sudo useradd -m sonar || true

# Set permissions
sudo chown -R sonar:sonar /opt/sonarqube-8.9.6.50800

# Kernel settings (required for SonarQube)
sudo sysctl -w vm.max_map_count=262144
sudo sysctl -w fs.file-max=65536

# Switch to sonar user and start SonarQube
sudo -u sonar bash <<EOF
ulimit -n 65536
ulimit -u 4096
/opt/sonarqube-8.9.6.50800/bin/linux-x86-64/sonar.sh start
EOF
