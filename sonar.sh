#!/bin/bash
set -e

# =========================================================
# SonarQube Latest + Dependency Check Plugin Setup
# Ubuntu 22.04 / 24.04
# =========================================================

SONAR_VERSION="25.5.0.107428"
SONAR_ZIP="sonarqube-${SONAR_VERSION}.zip"
SONAR_DIR="/opt/sonarqube-${SONAR_VERSION}"
SONAR_USER="sonar"

PLUGIN_VERSION="6.0.0"
PLUGIN_JAR="sonar-dependency-check-plugin-${PLUGIN_VERSION}.jar"

# =========================================================
# Update Packages
# =========================================================
sudo apt update -y

# =========================================================
# Install Java 17 + Required Tools
# =========================================================
sudo apt install -y \
openjdk-17-jdk \
wget \
curl \
unzip

# =========================================================
# Verify Java
# =========================================================
java -version

# =========================================================
# Create Sonar User
# =========================================================
sudo useradd -m -d /home/${SONAR_USER} -s /bin/bash ${SONAR_USER} || true

# =========================================================
# Download SonarQube
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
# Set Ownership
# =========================================================
sudo chown -R ${SONAR_USER}:${SONAR_USER} ${SONAR_DIR}

# =========================================================
# Kernel Settings
# =========================================================
echo "vm.max_map_count=524288" | sudo tee -a /etc/sysctl.conf
echo "fs.file-max=131072" | sudo tee -a /etc/sysctl.conf

sudo sysctl -p

# =========================================================
# User Limits
# =========================================================
echo "${SONAR_USER} soft nofile 131072" | sudo tee -a /etc/security/limits.conf
echo "${SONAR_USER} hard nofile 131072" | sudo tee -a /etc/security/limits.conf
echo "${SONAR_USER} soft nproc 8192" | sudo tee -a /etc/security/limits.conf
echo "${SONAR_USER} hard nproc 8192" | sudo tee -a /etc/security/limits.conf

# =========================================================
# Download Dependency Check Plugin
# =========================================================
cd /tmp

wget https://github.com/dependency-check/dependency-check-sonar-plugin/releases/download/${PLUGIN_VERSION}/${PLUGIN_JAR}

# =========================================================
# Install Plugin
# =========================================================
sudo cp ${PLUGIN_JAR} ${SONAR_DIR}/extensions/plugins/

# =========================================================
# Remove Old PID If Exists
# =========================================================
sudo rm -f ${SONAR_DIR}/bin/linux-x86-64/SonarQube.pid

# =========================================================
# Start SonarQube
# =========================================================
sudo -u ${SONAR_USER} bash <<EOF
ulimit -n 131072
ulimit -u 8192

${SONAR_DIR}/bin/linux-x86-64/sonar.sh stop || true
sleep 5
${SONAR_DIR}/bin/linux-x86-64/sonar.sh start
EOF

# =========================================================
# Wait for Startup
# =========================================================
echo "Waiting for SonarQube to start..."
sleep 40

# =========================================================
# Show Installed Plugins
# =========================================================
echo "===================================================="
echo "Installed Plugins:"
ls -lh ${SONAR_DIR}/extensions/plugins/
echo "===================================================="

# =========================================================
# Show Sonar Logs
# =========================================================
tail -n 50 ${SONAR_DIR}/logs/web.log

# =========================================================
# Final Info
# =========================================================
echo "===================================================="
echo "SonarQube Started Successfully"
echo "URL: http://<EC2-PUBLIC-IP>:9000"
echo "SonarQube Version : ${SONAR_VERSION}"
echo "Plugin Version    : ${PLUGIN_VERSION}"
echo "Java Version      : 17"
echo "===================================================="
