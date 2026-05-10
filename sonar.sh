#!/bin/bash
set -e

# =========================================================
# Latest SonarQube Community Edition Setup
# Ubuntu + Java 17
# =========================================================

SONAR_VERSION="25.5.0.107428"
SONAR_ZIP="sonarqube-${SONAR_VERSION}.zip"
SONAR_DIR="/opt/sonarqube-${SONAR_VERSION}"
SONAR_USER="sonar"

# =========================================================
# Update System
# =========================================================
sudo apt update -y

# =========================================================
# Install Java 17 + Utilities
# =========================================================
sudo apt install -y \
openjdk-17-jdk \
wget \
unzip \
curl

# =========================================================
# Verify Java
# =========================================================
java -version

# =========================================================
# Create Sonar User
# =========================================================
sudo useradd -m -d /home/${SONAR_USER} -s /bin/bash ${SONAR_USER} || true

# =========================================================
# Download Latest SonarQube
# =========================================================
cd /opt

if [ ! -f "${SONAR_ZIP}" ]; then
    sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/${SONAR_ZIP}
fi

# =========================================================
# Extract SonarQube
# =========================================================
if [ ! -d "${SONAR_DIR}" ]; then
    sudo unzip ${SONAR_ZIP}
fi

# =========================================================
# Permissions
# =========================================================
sudo chown -R ${SONAR_USER}:${SONAR_USER} ${SONAR_DIR}

# =========================================================
# Kernel Settings
# =========================================================
echo "vm.max_map_count=524288" | sudo tee -a /etc/sysctl.conf
echo "fs.file-max=131072" | sudo tee -a /etc/sysctl.conf

sudo sysctl -p

# =========================================================
# Limits
# =========================================================
echo "${SONAR_USER} soft nofile 131072" | sudo tee -a /etc/security/limits.conf
echo "${SONAR_USER} hard nofile 131072" | sudo tee -a /etc/security/limits.conf
echo "${SONAR_USER} soft nproc 8192" | sudo tee -a /etc/security/limits.conf
echo "${SONAR_USER} hard nproc 8192" | sudo tee -a /etc/security/limits.conf

# =========================================================
# Install Dependency-Check Plugin
# =========================================================
cd /tmp

wget -O sonar-dependency-check-plugin.jar \
https://github.com/dependency-check/dependency-check-sonar-plugin/releases/latest/download/sonar-dependency-check-plugin.jar

sudo cp sonar-dependency-check-plugin.jar \
${SONAR_DIR}/extensions/plugins/

# =========================================================
# Start SonarQube
# =========================================================
sudo -u ${SONAR_USER} bash <<EOF
ulimit -n 131072
ulimit -u 8192

${SONAR_DIR}/bin/linux-x86-64/sonar.sh stop || true
${SONAR_DIR}/bin/linux-x86-64/sonar.sh start
EOF

# =========================================================
# Wait for Startup
# =========================================================
sleep 40

# =========================================================
# Status
# =========================================================
echo "========================================================="
echo "SonarQube Started Successfully"
echo "URL: http://<EC2-PUBLIC-IP>:9000"
echo "SonarQube Version: ${SONAR_VERSION}"
echo "Java Version: 17"
echo "========================================================="

# =========================================================
# Show Logs
# =========================================================
tail -n 50 ${SONAR_DIR}/logs/sonar.log
