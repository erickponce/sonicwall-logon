#!/bin/bash
echo "\n[Installing SonicWall Auto Logon]\n"

HERE=$(pwd)
rm -Rf /tmp/sonicwall-logon
git clone https://github.com/erickponce/sonicwall-logon.git  /tmp/sonicwall-logon
cd /tmp/sonicwall-logon
sudo chmod a+x setup.sh
sudo bash setup.sh
cd $HERE
rm -Rf /tmp/sonicwall-logon
