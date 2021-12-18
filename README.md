# ZeroCar2w
Used to deploy a RaspberryPi Jelllyfin server via a hotspot

I use this as a portable server for the kids' iPads while in the car or flying on trips.

- Raspberry Pi Setup:
    - This was built for the Raspberry Pi Zero 2W

    - "Burn" the Raspbian Lite image of your choice to the SD card with another computer
        - Try Etcher by resin.io -- https://www.balena.io/etcher/

    - To allow for SSH access: https://bit.ly/2VUi53V
        - You can add a file to the boot partition called "ssh"
       ```
       touch ssh
       ```
        - OR...Create a blank txt file and save it to the boot partition as ssh

    - Have the RPi auto connect to you home router on boot so you can ssh in
        - Create a file in your text editor of choice called "wpa_supplicant.conf" with the below in the file
        ```
        ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
        update_config=1

        network={
            ssid="WIFI_ROUTER_NAME"
            psk="WIFI_ROUTER_PASSWORD"
            proto=RSN
            key_mgmt=WPA-PSK
            pairwise=CCMP
            auth_alg=OPEN
        }
        ```
        - Save the config file in the /boot partition

    - Install the SD card to the RPi and boot

    - SSH into the RPi through Putty or Terminal of choice https://bit.ly/2UzWyNA

    - Log in 

    - Run these commands below --
        ```
        sudo apt update
        sudo apt upgrade -y
        sudo apt install git -y
        git clone https://github.com/jrossmanjr/zerocar.git
        cd zerocar/
        sudo bash install.sh
        ```
        - Fill in data for the prompts

- The installer will prompt you for:
    - SMB Password - so you can connect thru SMB to drop files in
    - SSID Name - Name your WiFi hotspot
    - Hotspot Password - give the hotspot a password to keep freeloaders out of your stuff
    
- Access to RaspAP (RaspAP info: https://github.com/billz/raspap-webgui )  
    - Rebbot after instillation
    - Connect to the hotspot - go to ```10.0.0.1``` to access the RaspAP interface to change the network settings
- Setup Jellyfin
    - See this page for how to finish Jellyfin setup - https://pimylifeup.com/raspberry-pi-jellyfin/#firstsetup

-------------------------------------------------------------------------------------------------------------------------
Future
- Harden the OS to make it mostly read only -- to help with SD card corruption
- Develop an image that would install os on 4gb of the drive and then make a third partition, filling the drive, that is just for the media
-------------------------------------------------------------------------------------------------------------------------
