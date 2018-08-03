#!/bin/bash
echo "\n[SonicWall auto logon setup]\n"

read -p "Type your username, followed by [ENTER]: " USERNAME
read -s -p "Type your password, followed by [ENTER]: " PASSWORD

echo "\nGenerating config file..."
# Generate config file
cat auth.conf | sed -e "s/username = /username = $USERNAME/" > auth.temp
cat auth.temp | sed -e "s/password = /password = $PASSWORD/" > generated_auth.temp

echo "Installing dependences..."
PYTHON_ENV="/opt/sonicwall-logon/venv"
if [ ! -d "$PYTHON_ENV" ]; then
    if [ ! -f "/usr/bin/virtualenv" ]; then
        sudo apt-get install -yq virtualenv
    fi
    virtualenv -p /usr/bin/python3 $PYTHON_ENV
fi
source $PYTHON_ENV/bin/activate
$PYTHON_ENV/bin/pip install 'requests>=2.18.4' 'beautifulsoup4==4.6.0' 'configparser==3.5.0'

echo "Installing files..."
# Install files
mkdir -p /opt/sonicwall-logon
cp auto_logon.py /opt/sonicwall-logon/auto_logon.py
cp run.sh /opt/sonicwall-logon/run.sh

mkdir -p /etc/sonicwall-logon
cp generated_auth.temp /etc/sonicwall-logon/auth.conf
rm auth.temp
rm generated_auth.temp

echo "Configuring service..."
sudo cp sonicwall-logon.service /etc/systemd/system/sonicwall-logon.service
sudo systemctl enable /etc/systemd/system/sonicwall-logon.service
sudo systemctl restart sonicwall-logon.service
sudo systemctl status sonicwall-logon.service
sudo journalctl -f -n 100 -u sonicwall-logon.service --since today
