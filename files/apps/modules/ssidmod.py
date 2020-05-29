import os

def addnewssid( ssid , passwd, passwdc):
    if(len(passwd)<8):
        return 1
    elif(len(ssid)==0):
        return 2
    elif(passwd != passwdc):
        return 3
    else:
        f = open("passwd", "w")
        f.write("%s" % passwd )
        f.close()
        os.system('wpa_passphrase "%s" < passwd  >> /etc/wpa_supplicant/wpa_supplicant.conf' % ssid)
        os.remove("passwd")
        return 0
    