#!/bin/bash
sudo apt install figlet toilet
toilet -f future "\n[Installing SonicWall Auto Logon]\n"

rm -Rf /tmp/sonicwall-logon
git clone https://github.com/erickponce/sonicwall-logon.git  /tmp/sonicwall-logon
cd /tmp/sonicwall-logon
sudo chmod a+x setup.sh
sudo bash setup.sh
rm -Rf /tmp/sonicwall-logon
