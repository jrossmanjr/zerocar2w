#!/usr/bin/env bash
# ZeroCar2w Install Script
# by jrossmanjr -- https://github.com/jrossmnajr/zerocar2w
# Use a RaspberryPi as a WiFi hotspot to serve up files
#--------------------------------------------------------------------------------------------------------------------#
# Shoutout to the folks making PiHole, Adafruit, & PIRATEBOX for showing me the way and essentially teaching me BASH

# A lot of help came from ADAFRUIT:
# https://learn.adafruit.com/setting-up-a-raspberry-pi-as-a-wifi-access-point/install-software

# Thanks to SDESALAS who made a schweet node install script: https://github.com/sdesalas/node-pi-zero

# Thanks to RaspberryConnect.com for some refinement of the setup code

# RaspiAP by billz is the shit -- https://github.com/billz/raspap-webgui
#--------------------------------------------------------------------------------------------------------------------#
# MIT License
#Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
#documentation files (the "Software"), to deal in the Software without restriction, including without limitation
#the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
#and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO
#THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
#OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
#OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#--------------------------------------------------------------------------------------------------------------------#
echo ":::
███████╗███████╗██████╗  ██████╗  ██████╗ █████╗ ██████╗
╚══███╔╝██╔════╝██╔══██╗██╔═══██╗██╔════╝██╔══██╗██╔══██╗
  ███╔╝ █████╗  ██████╔╝██║   ██║██║     ███████║██████╔╝
 ███╔╝  ██╔══╝  ██╔══██╗██║   ██║██║     ██╔══██║██╔══██╗
███████╗███████╗██║  ██║╚██████╔╝╚██████╗██║  ██║██║  ██║
╚══════╝╚══════╝╚═╝  ╚═╝ ╚═════╝  ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝


    By - jrossmanjr   //   https://github.com/jrossmnajr/zerocar2w             "

# Find the rows and columns will default to 80x24 is it can not be detected
screen_size=$(stty size 2>/dev/null || echo 24 80)
rows=$(echo $screen_size | awk '{print $1}')
columns=$(echo $screen_size | awk '{print $2}')

# Divide by two so the dialogues take up half of the screen, which looks nice.
r=$(( rows / 2 ))
c=$(( columns / 2 ))
# Unless the screen is tiny
r=$(( r < 20 ? 20 : r ))
c=$(( c < 70 ? 70 : c ))


# Run this script as root or under sudo
if [[ $EUID -eq 0 ]];then
  echo "::: You are root."
else
  echo "::: sudo will be used."
  # Check if it is actually installed
  # If it isn't, exit because the install cannot complete
  if [[ $(dpkg-query -s sudo) ]];then
    export SUDO="sudo"
  else
    echo "::: Please install sudo or run this script as root."
    exit 1
  fi
fi

# Into popups and variable setup
whiptail --msgbox --title "ZeroCar2w automated installer" "\nThis installer turns your Raspberry Pi and Wifi Dongle into \nan awesome WiFi router and media streamer!" ${r} ${c}
whiptail --msgbox --title "ZeroCar2w automated installer" "\n\nFirst things first... Lets set up some variables!" ${r} ${c}
var1=$(whiptail --inputbox "Name the DLNA Server" ${r} ${c} ZeroCar2w --title "DLNA Name" 3>&1 1>&2 2>&3)
var2=$(whiptail --inputbox "Name the WiFi Hotspot" ${r} ${c} ZeroCar2w --title "Wifi Name" 3>&1 1>&2 2>&3)
var3=$(whiptail --passwordbox "Please enter a password for the WiFi hotspot (8 chars)" ${r} ${c} --title "HotSpot Password" 3>&1 1>&2 2>&3)
whiptail --msgbox --title "ZeroCar2w automated installer" "\n\nOk all the data has been entered...The install will now complete!" ${r} ${c}

#--------------------------------------------------------------------------------------------------------------------#
# Functions to setup the rest of the server
#--------------------------------------------------------------------------------------------------------------------#

function delete_junk() {
# delete all the junk that has nothing to do with being a lightweight server
  echo ":::"
  echo "::: Removing JUNK...from the trunk"
  $SUDO apt-get -y purge dns-root-data minecraft-pi python-minecraftpi wolfram-engine sonic-pi libreoffice scratch
  $SUDO apt-get autoremove
  echo "::: DONE!"
}

function install_the_things() {
  # installing samba server so you can connect and add files easily
  # installing jellyfin to serve up your shit nicely
  echo ":::"
  echo "::: Installing Samba & Jellyfin"
  $SUDO apt update 
  $SUDO apt install -y apt-transport-https
  $SUDO apt upgrade -y
  curl https://repo.jellyfin.org/debian/jellyfin_team.gpg.key | gpg --dearmor | sudo tee /usr/share/keyrings/jellyfin-archive-keyring.gpg >/dev/null
  echo "deb [signed-by=/usr/share/keyrings/jellyfin-archive-keyring.gpg arch=$( dpkg --print-architecture )] https://repo.jellyfin.org/debian $( lsb_release -c -s ) main" | sudo tee /etc/apt/sources.list.d/jellyfin.list
  $SUDO apt update
  $SUDO apt install -y wget samba samba-common-bin apt-transport-https jellyfin exfat-utils
  echo "::: DONE installing all the things!"
}

function edit_samba() {
  # editing Samba
  echo ":::"
  echo "::: Editing Samba... "
  echo "::: You will enter a password for your Folder Share next."
  $SUDO smbpasswd -a pi
  $SUDO cp /etc/samba/smb.conf /etc/samba/smb.conf.bkp
  echo '[Mediadrive]
        comment = Public Storage
        path = /home/
        create mask = 0775
        directory mask = 0775
        read only = no
        browsable = yes
        writable = yes
        guest ok = yes
        guest only = yes' | sudo tee --append /etc/samba/smb.conf > /dev/null
  $SUDO /etc/init.d/samba restart
  echo "::: DONE!"
}

function instal_raspiap() {
  echo ":::"
  echo "::: Installing Access Pont Software..."
  echo "************************"
  echo "*** DO NOT RESTART!! ***"
  echo "************************"
  wget -q https://git.io/voEUQ -O /tmp/raspap && bash /tmp/raspap
}

function edit_hostapd() {
  # editing hostapd and associated properties
  echo ":::"
  echo "::: Editing hostapd"
  $SUDO echo 'driver=nl80211
ctrl_interface=/var/run/hostapd
ctrl_interface_group=0
beacon_int=100
auth_algs=1

wpa_key_mgmt=WPA-PSK
channel=1
hw_mode=g
interface=wlan0
wpa=2
wpa_pairwise=CCMP
rsn_pairwise=CCMP

country_code=US

macaddr_acl=0
ignore_broadcast_ssid=0
ieee80211n=1
#ht_capab=[HT40][SHORT-GI-20][DSSS_CCK-40]

### SSID AND PASSWORD ###
' > /etc/hostapd/hostapd.conf
  echo "ssid=$var2" | sudo tee --append /etc/hostapd/hostapd.conf > /dev/null
  echo "wpa_passphrase=$var3" | sudo tee --append /etc/hostapd/hostapd.conf > /dev/null
  echo "::: DONE!"
}

function edit_dhcpdconf() {
  # editing dhcpcd to stop it from starting the wifi network so the autostart script can
  echo ":::"
  echo "::: Editing dhcpd.conf"
  $SUDO echo '#Defaults from Raspberry Pi configuration
hostname
clientid
persistent
option rapid_commit
option domain_name_servers, domain_name, domain_search, host_name
option classless_static_routes
option ntp_servers
require dhcp_server_identifier
slaac private
nohook lookup-hostname
nohook wpa_supplicant

interface wlan0
static ip_address=10.0.0.1/24
static routers=10.0.0.1
static domain_name_server=1.1.1.1 8.8.8.8' > /etc/dhcpcd.conf
  echo "::: DONE!"
}

function edit_dnsmasq() {
  # editing dnsmasq
  echo ":::"
  echo "::: Editing dnsmasq.conf"
  $SUDO echo "domain-needed
interface=wlan0
dhcp-range=10.0.0.2,10.0.0.245,255.255.255.0,24h" > /etc/dnsmasq.conf
  echo "::: DONE"
}

function finishing_touches() {
  # restarting
  echo "::: Finishing touches..."
  $SUDO chmod -R 777 /home/pi
  $SUDO sysctl -p
  whiptail --msgbox --title "ZeroCar2w automated installer" "\n\nThe install process has finieshed. \nPlease restart the Pi and then connect to the hotspot. \nThen open VLC on your devices and go to network and you should see the server \n" ${r} ${c}
}

function edit_minidlna() {
  # editing minidlna
  echo ":::"
  echo -n "::: Editing minidlna"
  $SUDO mkdir /home/pi/minidlna
  $SUDO mkdir /home/pi/videos
  $SUDO chmod -R 777 /home/pi
  $SUDO cp /etc/minidlna.conf /etc/minidlna.conf.bkp
  $SUDO echo "user=root
media_dir=V,/home/pi/videos/
db_dir=/home/pi/minidlna/
log_dir=/var/log
port=8200
inotify=yes
enable_tivo=no
strict_dlna=no
album_art_names=Folder.jpg/folder.jpg/Thumb.jpg/thumb.jpg/movie.tbn/movie.jpg/Poster.jpg/poster.jpg
notify_interval=900
serial=12345678
model_number=1
root_container=B" > /etc/minidlna.conf
  echo "model_name=$var1" | sudo tee --append /etc/minidlna.conf > /dev/null
  echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf
  $SUDO update-rc.d minidlna defaults
  $SUDO systemctl enable minidlna
  echo "::: DONE!"
}

delete_junk
install_the_things
edit_samba
edit_minidlna
instal_raspiap
edit_hostapd
edit_dhcpdconf
edit_dnsmasq
finishing_touches
