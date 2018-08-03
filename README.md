# Sonicwall Logon
Linux service that automatically keeps SonicWall user authenticated.  
Execute authentications with default interval of 600 minutes or with value configured in auth.conf

Installation
--------------

```bash
  git clone https://github.com/erickponce/sonicwall-logon.git
  cd sonicwall-logon
  sudo bash setup.sh
```
  
It will ask you for a SonicWall username and password.
A file like the below with the credentials will be created in /etc/sonicwall-logon/auth.conf

```
[Auth Credentials]
username = <your username>
password = <your password>

[Server Info]
host = 10.0.0.10
port = 444
login_duration = 600
```

If you change your password, update credentials in this file and execute:
```bash
  sudo service sonicwall-logon restart
```


If you want install, use this command:
```bash
  curl -H 'Cache-Control: no-cache' https://raw.githubusercontent.com/erickponce/sonicwall-logon/master/install.sh?$(date +%s) | bash -
```
or
```bash
  bash <(curl -s https://raw.githubusercontent.com/erickponce/sonicwall-logon/master/install.sh)
```
