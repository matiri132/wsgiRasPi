# Automated NGINX-WSGI Instalation Script
## Install an SSID changer Script working on WSGI
### This is a full automated NGINX-WSGI instalation script for RaspberryPi 
##### This script set-up a NGINX-Webserver serving Python APPs

**Installing Kiosk:**
1. Clone the repo:
```
git clone https://github.com/matiri132/wsgiRasPi
```
2. Give execution permissions:
```
sudo chmod +x installWSGI.sh
```
3. Update / upgrade
```
sudo apt update
sudo apt upgrade
```
4. Setup:
-You can choose some parameters in the installWSGI.sh file all are listed at the begining of the file, so you can change it with nano.

5. Install (with SUDO):
```
sudo ./installWSGI.sh USER install all
```
-Replace USER by your current user.
-if you use "instal all"  the script will install all necesary packages.
-If you make any changes in the installation file  you only need to use install and reboot.

6. Work:
```
-You now have a NGINX Server working with WSGI to serve python scripts.
-You can add new functions in the server aplication located in ~/APPDIR (Seted on the install script).
-The server has an SSID changer working on localhost/ssid. (localhost as default se the install script).
```


7. Uninstall :
```
sudo ./installWSGI.sh USER uninstall all
```
-USER must be the same user thats run install before.
-This function power off nginx, remove the service what handle WSGI, and remove all server directory.

