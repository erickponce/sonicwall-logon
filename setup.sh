#!/bin/bash
echo "\n[SonicWall auto logon setup]\n"

echo  "\nGenerating config file..."
# Ask Username and Password from user
unset -v USERNAME
read -p "Type your username, followed by [ENTER]: " USERNAME
unset -v PASSWORD
read -s -p "Type your password, followed by [ENTER]: " PASSWORD

# Generate config file
sed -i "s/username = /username = $USERNAME/" auth.conf
sed -i "s/password = /password = $PASSWORD/" auth.conf
unset -v USERNAME
unset -v PASSWORD

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
sudo mkdir -p /opt/sonicwall-logon
sudo cp auto_logon.py /opt/sonicwall-logon/auto_logon.py
sudo cp run.sh /opt/sonicwall-logon/run.sh

sudo mkdir -p /etc/sonicwall-logon
sudo cp auth.conf /etc/sonicwall-logon/auth.conf

echo "Configuring service..."
sudo cp sonicwall-logon.service /etc/systemd/system/sonicwall-logon.service
sudo systemctl enable /etc/systemd/system/sonicwall-logon.service
sudo systemctl restart sonicwall-logon.service
sudo systemctl status sonicwall-logon.service
#sudo journalctl -f -n 100 -u sonicwall-logon.service --since today
