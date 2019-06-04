#!/bin/bash

# Upon execution this script will install the software needed for using the Little Endian.

# Updating the software.
sudo apt-get update
sudo apt update
sudo apt-get upgrade -y

# Installing NodeJS.
sudo apt-get install curl -y
sudo curl -sl https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install nodejs -y

# Installing git.
sudo apt-get install git -y

# Setting up the SSH key.
echo .ssh; echo key | sudo ssh-keygen -t rsa

# Downloading the Endian software.

# Building the Endian software.
sudo apt-get install unzip -y
sudo unzip /home/pi/Downloads/CoderDojo-LittleEndian.zip -d /home/pi
cd /home/pi/CoderDojo-LittleEndian/src/react-application/
sudo npm i && npm run build
cd /home/pi/CoderDojo-LittleEndian/src/socket-server/
npm i

# Starting the software at boot.
sudo npm install pm2 -g
pm2 startup
sudo env PATH=$PATH:/usr/bin/usr/lib/node_modules/pm2/bin/pm2 startup systemd -u pi --hp /home/pi
cd /home/pi/CoderDojo-LittleEndian/src/react-application/
pm2 start node_modules/react-scripts/bin/react-scripts.js --name react-application -- start
pm2 save
cd /home/pi/CoderDojo-LittleEndian/src/socket-server/
pm2 start server.js
pm2 save

# Installing the acces point.
sudo apt-get install isc-dhcp-server
sudo apt-get install -y dnsmasq hostapd
sudo systemctl stop dnsmasq
sudo systemctl stop hostapd
sudo touch /etc/dhcp/dhcpcd.conf
echo interface wlan0 >> /etc/dhcp/dhcpcd.conf
echo static ip_address=192.168.2.10/24 >> /etc/dhcp/dhcpcd.conf
echo nohook wp_supplicant >> /etc/dhcp/dhcpcd.conf
sudo systemctl restart isc-dhcp-server

# Configuring DNSMASQ.
echo interface=wlan0 >> /etc/dnsmasq.conf
echo dhcp-range=192.168.2.10,192.168.2.142,255.255.255.0,24 >> /etc/dnsmasq.conf

# Setting up the SSID.
sudo touch /etc/hostapd/hostapd.conf
echo interface=wlan0 >> /etc/hostapd/hostapd.conf
echo nl80211 >> /etc/hostapd/hostapd.conf
echo ssid=Endian >> /etc/hostapd/hostapd.conf
echo hw_mode=g >> /etc/hostapd/hostapd.conf
echo channel=7 >> /etc/hostapd/hostapd.conf
echo wmm_enabled=0 >> /etc/hostapd/hostapd.conf
echo macaddr_acl=0 >> /etc/hostapd/hostapd.conf
echo auth_algs=1 >> /etc/hostapd/hostapd.conf
echo ignore_broadcast_ssid=0 >> /etc/hostapd/hostapd.conf
echo wpa=2 >> /etc/hostapd/hostapd.conf
echo wpa_passphrase=ReallySecurePassword >> /etc/hostapd/hostapd.conf
echo wpa_key_mgmt=WPA-PSK >> /etc/hostapd/hostapd.conf
echo wpa_pairwise=TKIP >> /etc/hostapd/hostapd.conf
echo rsn_pairwise=CCMP >> /etc/hostapd/hostapd.conf
echo DAEMON_CONF="/etc/hostapd/hostapd.conf" >> /etc/default/hostapd
sudo systemctl start hostapd
sudo systemctl start dnsmasq

# Setting up the firewall.
echo net.ipv4.ip_forward=1 >> /etc/sysctl.conf
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo sh -c "iptables-save > /etc/iptables.ipv4.nat"
sudo touch /etc/rc.local
echo iptables-restore < /etc/iptables.ipv4.nat
