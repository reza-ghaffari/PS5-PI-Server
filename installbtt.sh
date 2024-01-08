#!/bin/bash

PITYP=$(tr -d '\0' </proc/device-tree/model) 
if [[ $PITYP != "BigTreeTech CB1" ]] ;then
echo -e '\033[33mThis script is for the BTT PI only,\033[31m you cannot run it on this board.\033[0m'
exit;
fi
if [[ $(hostname) == "ps5" ]] ;then
echo -e '\033[33mYou have run this script already,\033[31m you cannot run it again.\033[0m'
exit;
fi
echo -e '\033[32mInstalling PS5 PI Server on\033[33m '$PITYP'\033[0m'
sudo apt install dnsmasq nginx -y
sudo sed -i 's/#domain-needed/domain-needed/g' /etc/dnsmasq.conf
sudo sed -i 's/#bogus-priv/bogus-priv/g' /etc/dnsmasq.conf
sudo sed -i 's/#expand-hosts/expand-hosts/g' /etc/dnsmasq.conf
sudo sed -i 's^#conf-file=/etc/dnsmasq.more.conf^conf-file=/etc/dnsmasq.more.conf^g' /etc/dnsmasq.conf
sudo openssl req -subj "/C=US/O=ps5/CN=ps5.local" -x509 -nodes -days 8192 -newkey rsa:2048 -keyout /etc/nginx/sites-available/cert.key -out /etc/nginx/sites-available/cert.crt
sudo sed -i 's/# listen 443 ssl/ listen 443 ssl/g' /etc/nginx/sites-available/default
sudo sed -i 's/# listen \[::\]:443 ssl/ listen \[::\]:443 ssl/g' /etc/nginx/sites-available/default
sudo sed -i 's/server_name _/server_name ps5.local/g' /etc/nginx/sites-available/default
sudo sed -i 's^# SSL configuration^# SSL configuration\r\n	 ssl_certificate /etc/nginx/sites-available/cert.crt;\r\n	 ssl_certificate_key /etc/nginx/sites-available/cert.key;^g' /etc/nginx/sites-available/default
echo '#!/bin/bash
coproc read -t 20 && wait "$!" || true
sudo rm /etc/dnsmasq.more.conf
while [ "$(hostname -I)" = "" ]; do
  sleep 1
done
IP=$(hostname -I | cut -f1 -d" ")
echo "address=/playstation.com/127.0.0.1
address=/manuals.playstation.net/$IP
address=/playstation.net/127.0.0.1
address=/playstation.org/127.0.0.1
address=/akadns.net/127.0.0.1
address=/akamai.net/127.0.0.1
address=/akamaiedge.net/127.0.0.1
address=/edgekey.net/127.0.0.1
address=/edgesuite.net/127.0.0.1
address=/llnwd.net/127.0.0.1
address=/scea.com/127.0.0.1
address=/sonyentertainmentnetwork.com/127.0.0.1
address=/ribob01.net/127.0.0.1
address=/cddbp.net/127.0.0.1
address=/nintendo.net/127.0.0.1
address=/ea.com/127.0.0.1" | sudo tee -a /etc/dnsmasq.more.conf
sudo systemctl start dnsmasqh.service' | sudo tee -a /etc/dstart.sh
sudo cp -r document /var/www/html/
sudo touch /var/www/html/index.html
echo "<html><meta HTTP-EQUIV='REFRESH' content='0; url=/document/index.html'></html>" | sudo tee -a /var/www/html/index.html
sudo sed -i 's^"exit 0"^"exit"^g' /etc/rc.local
sudo sed -i 's^exit 0^sudo bash ./etc/dstart.sh \& \n\nexit 0^g' /etc/rc.local
sudo rm /etc/dnsmasq.more.conf
IP=$(hostname -I | cut -f1 -d' ')
echo "address=/playstation.com/127.0.0.1
address=/manuals.playstation.net/$IP
address=/playstation.net/127.0.0.1
address=/playstation.org/127.0.0.1
address=/akadns.net/127.0.0.1
address=/akamai.net/127.0.0.1
address=/akamaiedge.net/127.0.0.1
address=/edgekey.net/127.0.0.1
address=/edgesuite.net/127.0.0.1
address=/llnwd.net/127.0.0.1
address=/scea.com/127.0.0.1
address=/sonyentertainmentnetwork.com/127.0.0.1
address=/ribob01.net/127.0.0.1
address=/cddbp.net/127.0.0.1
address=/nintendo.net/127.0.0.1
address=/ea.com/127.0.0.1" | sudo tee -a /etc/dnsmasq.more.conf
while true; do
read -p "$(printf '\r\n\r\n\033[36mDo you want to setup a WIFI access point? (Y|N): \033[0m')" wapq
case $wapq in
[Yy]* ) 
sudo apt install dhcpcd5 iptables net-tools -y
echo -e "\r\ninterface wlan1
    static ip_address=10.0.0.1/24
    nohook wpa_supplicant" | sudo tee -a /etc/dhcpcd.conf
echo -e "\r\ninterface=wlan1\r\ndhcp-range=10.0.0.2,10.0.0.20,255.255.255.0,24h\r\ninterface=wlan0\r\ninterface=end0" | sudo tee -a /etc/dnsmasq.conf
while true; do
read -p "$(printf '\r\n\r\n\033[36mDo you want to set a SSID and password for the wifi access point?\r\nif you select no then these defaults will be used\r\n\r\nSSID=\033[33mPS5_WEB_AP\r\n\033[36mPASS=\033[33mpassword\r\n\r\n\033[36m(Y|N)?: \033[0m')" wapset
case $wapset in
[Yy]* ) 
while true; do
read -p  "$(printf '\033[33mEnter SSID: \033[0m')" APSSID
case $APSSID in
"" ) 
 echo -e '\033[31mCannot be empty!\033[0m';;
 * )  
if grep -q '^[0-9a-zA-Z_ -]*$' <<<$APSSID ; then 
if [ ${#APSSID} -le 1 ]  || [ ${#APSSID} -ge 33 ] ; then
echo -e '\033[31mSSID must be between 2 and 32 characters long\033[0m';
else 
break;
fi
else 
echo -e '\033[31mSSID must only contain alphanumeric characters\033[0m'; 
fi
esac
done
while true; do
read -p "$(printf '\033[33mEnter password: \033[0m')" APPSWD
case $APPSWD in
"" ) 
 echo -e '\033[31mCannot be empty!\033[0m';;
 * )  
if [ ${#APPSWD} -le 7 ]  || [ ${#APPSWD} -ge 64 ] ; then
echo -e '\033[31mPassword must be between 8 and 63 characters long\033[0m';
else 
break;
fi
esac
done
echo -e '\033[36mUsing custom settings\r\n\r\nSSID=\033[33m'$APSSID'\r\n\033[36mPASS=\033[33m'$APPSWD'\r\n\r\n\033[0m'
mkdir /etc/hostapd/
touch /etc/hostapd/hostapd.conf
echo 'SSID="'$APSSID'"
PASS="'$APPSWD'"' | sudo tee -a /etc/hostapd/hostapd.conf
break;;
[Nn]* ) 
echo -e '\033[36mUsing default settings\r\n\r\nSSID=\033[33mPS5_WEB_AP\r\n\033[36mPASS=\033[33mpassword\r\n\r\n\033[0m'
mkdir /etc/hostapd/
touch /etc/hostapd/hostapd.conf
echo 'SSID="PS5_WEB_AP"
PASS="password"' | sudo tee -a /etc/hostapd/hostapd.conf
break;;
* ) echo -e '\033[31mPlease answer Y or N\033[0m';;
esac
done
echo '#!/bin/bash
coproc read -t 20 && wait "$!" || true
sudo rm /etc/dnsmasq.more.conf
while [ "$(hostname -I)" = "" ]; do
  sleep 1
done
IP=$(hostname -I | cut -f1 -d" ")
echo "address=/playstation.com/127.0.0.1
address=/manuals.playstation.net/$IP
address=/playstation.net/127.0.0.1
address=/playstation.org/127.0.0.1
address=/akadns.net/127.0.0.1
address=/akamai.net/127.0.0.1
address=/akamaiedge.net/127.0.0.1
address=/edgekey.net/127.0.0.1
address=/edgesuite.net/127.0.0.1
address=/llnwd.net/127.0.0.1
address=/scea.com/127.0.0.1
address=/sonyentertainmentnetwork.com/127.0.0.1
address=/ribob01.net/127.0.0.1
address=/cddbp.net/127.0.0.1
address=/nintendo.net/127.0.0.1
address=/ea.com/127.0.0.1" | sudo tee -a /etc/dnsmasq.more.conf
sudo systemctl start dnsmasqh.service
sleep 2
. /etc/hostapd/hostapd.conf
nmcfile="/etc/NetworkManager/system-connections/Hotspot.nmconnection"
makecon(){
sudo nmcli connection delete Hotspot
sudo rm /etc/NetworkManager/system-connections/*Hotspot*
sudo nmcli connection add type wifi ifname wlan1 con-name Hotspot ssid "$SSID"
sudo nmcli connection modify Hotspot 802-11-wireless.band bg ipv4.method shared
sudo nmcli connection modify Hotspot 802-11-wireless.mode ap
sudo nmcli connection modify Hotspot wifi-sec.key-mgmt wpa-psk
sudo nmcli connection modify Hotspot wifi-sec.group ccmp
sudo nmcli connection modify Hotspot wifi-sec.pairwise ccmp
sudo nmcli connection modify Hotspot wifi-sec.proto rsn
sudo nmcli connection modify Hotspot wifi-sec.psk "$PASS"
sudo nmcli connection modify Hotspot ipv4.addresses 10.0.0.1/24
sudo nmcli connection modify Hotspot ipv6.method disabled
sudo nmcli connection up Hotspot
}
if [ ! -e $nmcfile ] ;then
makecon
fi
NSSID=$(sed -nr "/^\[wifi\]/ { :l /^ssid[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;}" $nmcfile)
NPSK=$(sed -nr "/^\[wifi-security\]/ { :l /^psk[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;}" $nmcfile)
if [[ $PASS != $NPSK  ||  $SSID != $NSSID ]] ;then
makecon
fi
sudo iptables -P INPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -P OUTPUT ACCEPT
sudo iptables -t nat -F
sudo iptables -t mangle -F
sudo iptables -F
sudo iptables -X
sudo sysctl net.ipv4.ip_forward=1
sudo iptables -t nat -A POSTROUTING -s 10.0.0.0/24 ! -d 10.0.0.0/24 -j MASQUERADE' | sudo tee -a /etc/startap.sh
sudo rm /etc/dstart.sh
sudo sed -i 's^sudo bash ./etc/dstart.sh \&^^g' /etc/rc.local
sudo sed -i 's^exit 0^sudo bash ./etc/startap.sh \& \n\nexit 0^g' /etc/rc.local
echo -e '\033[32mWifi AP installed\033[0m'
break;;
[Nn]* ) echo -e '\033[35mSkipping Wifi AP install\033[0m'
break;;
* ) echo -e '\033[31mPlease answer Y or N\033[0m';;
esac
done
while true; do
read -p "$(printf '\r\n\r\n\033[36mDo you want to install a FTP server? (Y|N):\033[0m ')" ftpq
case $ftpq in
[Yy]* ) 
sudo apt-get install vsftpd -y
USR=$(sudo groupmems -g users -l | cut -f1 -d' ')
echo "anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=077
allow_writeable_chroot=YES
chroot_local_user=YES
user_sub_token=$USR
local_root=/var/www/html" | sudo tee -a /etc/vsftpd.conf
sudo chmod 775 /var/www/html/
sudo sed -i 's^exit 0^^g' /etc/rc.local
echo -e "sudo chown -R "$USR":"$USR" /var/www/html/\n\nexit 0" | sudo tee -a /etc/rc.local
echo -e '\033[32mFTP Installed\033[0m'
break;;
[Nn]* ) echo -e '\033[35mSkipping FTP install\033[0m'
break;;
* ) echo -e '\033[31mPlease answer Y or N\033[0m';;
esac
done
while true; do
read -p "$(printf '\r\n\r\n\033[36mnDo you want to setup a SAMBA share? (Y|N):\033[0m ')" smbq
case $smbq in
[Yy]* ) 
sudo apt-get install samba samba-common-bin -y
echo "[www]
path = /var/www/html
writeable=Yes
create mask=0777
read only = no
directory mask=0777
force create mask = 0777
force directory mask = 0777
force user = root
force group = root
public=yes" | sudo tee -a /etc/samba/smb.conf
sudo systemctl unmask smbd
sudo systemctl enable smbd
echo -e '\033[32mSamba installed\033[0m'
break;;
[Nn]* ) echo -e '\033[35mSkipping SAMBA install\033[0m'
break;;
* ) echo -e '\033[31mPlease answer Y or N\033[0m';;
esac
done
echo -e '\033[36mInstall complete,\033[33m Rebooting\033[0m'
sudo systemctl stop NetworkManager
sudo systemctl stop dhcpcd.service
sudo systemctl disable dnsmasq.service
sudo systemctl stop dnsmasq.service
sudo mv /usr/sbin/dnsmasq /usr/sbin/dnsmasqh
sudo mv /etc/init.d/dnsmasq /etc/init.d/dnsmasqh
sudo sed -i 's^/usr/sbin/dnsmasq^/usr/sbin/dnsmasqh^g' /etc/init.d/dnsmasqh
HSTN=$(hostname | cut -f1 -d' ')
sudo sed -i "s^$HSTN^ps5^g" /etc/hosts
sudo sed -i "s^$HSTN^ps5^g" /etc/hostname
sudo reboot