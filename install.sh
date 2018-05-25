#!/bin/bash
echo "\n[Installing SonicWall Auto Logon]\n"

rm -Rf /tmp/sonicwall-logon
git clone https://github.com/erickponce/sonicwall-logon.git  /tmp/sonicwall-logon
cd /tmp/sonicwall-logon
sudo ./setup.sh
