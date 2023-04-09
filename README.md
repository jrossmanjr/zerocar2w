# ZeroCar2w
Used to deploy a RaspberryPi minidlna server via a hotspot

I use this as a portable server for the kids' iPads while in the car or flying on trips.

- Raspberry Pi Setup:
    - This was built for the Raspberry Pi Zero 2W

    - "Burn" the Raspbian Lite image of your choice to the SD card with another computer using Raspberry Pi Imager
        - https://www.raspberrypi.com/software/
        
    - Install the SD card to the RPi and boot

    - SSH into the RPi through Putty or Terminal of choice https://bit.ly/2UzWyNA

    - Log in 

    - Run these commands below --
        ```
        sudo apt update
        sudo apt upgrade -y
        sudo apt install git -y
        git clone https://github.com/jrossmanjr/zerocar2w.git
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

- Access Server
    - Use VLC or another DLNA player to access the server when on the hotspot

-------------------------------------------------------------------------------------------------------------------------
Future
- Harden the OS to make it mostly read only -- to help with SD card corruption
- Develop an image that would install os on 4gb of the drive and then make a third partition, filling the drive, that is just for the media
-------------------------------------------------------------------------------------------------------------------------
