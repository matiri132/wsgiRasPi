#!/bin/bash
##########SETABLES######
H_USER=$1
APPDIR="/home/${H_USER}/webapps"
APPNAME='myapp'
HOST_NAME='0.0.0.0'
DOMAINNAME='localhost'
#########################

WD=$(pwd)

install_packages (){
	#Python dep
	apt install python3-dev build-essential libssl-dev libffi-dev python3-setuptools -y

	#Nginx dep
	if [ ! -x "$(command -v nginx))" ]; then
		echo "Installing NGINX..."
		apt install nginx -y
	fi
	#Sed omstaññ
	if [ ! -x "$(command -v sed))" ]; then
		echo "Installing SED..."
		apt install sed -y
	fi

	echo "INSTALL Python PACKAGES..."
	if [ ! -x "$(command -v pip3))" ]; then
		echo "Installing PIP..."
		apt install python3-pip -y
	fi

	pip3 install wheel flask
	pip3 install uwsgi
}

case $2 in
	install)
		#Preparing config files
		cp ${WD}/files/apps/ssidapp.py.bk ${WD}/ssidapp.py
		sed -i "s/HOSTNAME/${HOST_NAME}/g" ${WD}/ssidapp.py
		cp ${WD}/files/data/ssidappini.bk ${WD}/ssidappini
		sed -i "s/APPDIR/\/home\/${H_USER}\/webapps/g" ${WD}/ssidappini
		sed -i "s/APPNAME/${APPNAME}/g" ${WD}/ssidappini
		cp ${WD}/files/data/ssidservice.bk ${WD}/ssidservice
		sed -i "s/APPNAME/${APPNAME}/g" ${WD}/ssidservice
		sed -i "s/APPDIR/\/home\/${H_USER}\/webapps/g" ${WD}/ssidservice
		cp ${WD}/files/data/ssidnginx.bk ${WD}/ssidnginx
		sed -i "s/DOMAINNAME/${DOMAINNAME}/g" ${WD}/ssidnginx
		sed -i "s/APPNAME/${APPNAME}/g" ${WD}/ssidnginx

		echo "INSTALLING DEPENDENCIES..."
		#Install dependencies
		if [ $3 == 'full' ]
		then
			install_packages
		fi

		echo "SETUP FLASK APP..."
		if [ ! -d ${APPDIR} ]
		then
			mkdir ${APPDIR}
			mkdir ${APPDIR}/templates
			mkdir ${APPDIR}/modules
			
		fi

		if [ -e /etc/wpa_supplicant/wpa_supplicant.conf ]
		then
			#Install application
			chmod 770 /etc/wpa_supplicant/wpa_supplicant.conf
			cp ${WD}/ssidappini ${APPDIR}/${APPNAME}.ini
			cp ${WD}/ssidapp.py ${APPDIR}/ssidapp.py
			cp ${WD}/files/apps/modules/ssidmod.py ${APPDIR}/modules/ssidmod.py
			cp ${WD}/files/apps/templates/ssidform.html ${APPDIR}/templates/ssidform.html
			sudo chown www-data:www-data ${APPDIR}
			#Creating SERVICE
			cp ${WD}/ssidservice /etc/systemd/system/${APPNAME}.service
			systemctl enable ${APPNAME}
			systemctl start ${APPNAME}

			#Configure NGINX
			if [ -e /etc/nginx/sites-enabled/default ]
			then
			rm /etc/nginx/sites-enabled/default
			fi
			cp ${WD}/ssidnginx /etc/nginx/sites-available/${APPNAME}
			ln -s /etc/nginx/sites-available/${APPNAME} /etc/nginx/sites-enabled/
			if [ -x "$(command -v ufw))" ]
			then
				echo "Configure firewall..."
				ufw allow 'Nginx Full'
			fi
			systemctl restart nginx
			rm ssidservice ssidappini ssidnginx ssidapp.py 
		else
			echo "Cant install, problems with wpa_supplicant..."
		fi
	;;

	uninstall)
		#Remove WEBAPP
		echo "Removing WebApp..."
		rm -Rf ${APPDIR}
		#Remove Service
		echo "Removing service..."
		systemctl stop ${APPNAME}
		systemctl disable ${APPNAME}
		rm /etc/systemd/system/${APPNAME}.service
		echo "Remove socket..."
		rm /tmp/${APPNAME}.sock
		echo "Reinitializing nginx..."
		#Set default nginx
		rm -f /etc/nginx/sites-enabled/${APPNAME}
		rm -f /etc/nginx/sites-available/${APPNAME}
		ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/
		echo "Reloading nginx..."
		systemctl reload nginx
		systemctl daemon-reload
		echo "Done."
	;;
esac
if [ $1 == 'help' ]
then 
	echo "USE: installWSGI USER UN/INSTALL OPT"
	echo "1: installWSGI pi install -> Basic install"
	echo "2: installWSGI pi install full -> Install all needed package"
	echo "3: installWSGI pi uninstall -> Uninstall web server and apps"
fi

