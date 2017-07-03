#!/bin/bash
echo "\n[SonicWall auto logon setup]\n"

read -p "Type your username, followed by [ENTER]: " USERNAME
read -s -p "Type your password, followed by [ENTER]: " PASSWORD

echo "\nGenerating config file..."
# Generate config file
cat auth.conf | sed -e "s/username = /username = "$USERNAME"/" > auth.temp
cat auth.temp | sed -e "s/password = /password = "$PASSWORD"/" > generated_auth.temp

echo "Installing dependences..."
pip install 'requests>=2.6.2' 'BeautifulSoup>=3.2.1'

echo "Installing files..."
# Install files
mkdir -p /opt/sonicwall-logon
cp auto_logon.py /opt/sonicwall-logon/auto_logon.py
cp run.sh /opt/sonicwall-logon/run.sh

mkdir -p /etc/sonicwall-logon
cp generated_auth.temp /etc/sonicwall-logon/auth.conf
rm auth.temp
rm generated_auth.temp

cp sonicwall-logon /etc/init.d/sonicwall-logon

echo "Setting permissions..."
# Set permissions
chmod +rwx /etc/init.d/sonicwall-logon

echo "Configuring service..."
# Make service start with OS
update-rc.d sonicwall-logon defaults

# Start service
service sonicwall-logon restart
