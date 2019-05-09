# Raspberry-PI-Link-Labs-LoRaWAN-Gateway

Reference setup for LoRaWAN Gateway based on a Raspberry Pi host and the Link Labs [Gateway Board](http://store.link-labs.com/products/lorawan-raspberry-pi-board).

## Hardware setup

[schematic](http://forum.thethingsnetwork.org/uploads/default/original/1X/dbdd7deb2b854bb7104019d79683f2d1ae9f1c51.pdf)

| Description | RPi pin | BCM GPIO | WiringPi | Mode
| :---: | :---: | :---: | :---: | :---:
| SX1301 Reset  | 29 | GPIO5  | 21 | output
| GPS Reset     | 31 | GPIO6  | 22 | output
| GPS PPS       | 7  | GPIO4  | 7  | input  
| SPI CLK       | 23 |        |    | 
| SPI MISO      | 21 |        |    | 
| SPI MOSI      | 19 |        |    | 
| SPI NSS       | 24 |        |    | 
| LED 1         | 13 | GPIO27 | 2  | output
| LED 2         | 22 | GPIO25 | 6  | output

Now you're ready to start the software setup.

## Software setup (Raspbian)

- Download [Raspbian Jessie Lite](https://www.raspberrypi.org/downloads/raspbian/)
- Follow the [installation instruction](https://www.raspberrypi.org/documentation/installation/installing-images/README.md) to create the SD card
- Connect an Ethernet cable to the RPi
- Plug the power supply of the RPi which will also power the concentrator board (**WARNING**: never power up without the antenna!)
- From a computer in the same LAN, `ssh` into the RPi using the default hostname:

        $ ssh pi@raspberrypi.local

- Use `raspi-config` utility to: 1) disable graphical boot mode and 2) to **enable SPI** (`Advanced options -> SPI`):

        $ sudo raspi-config

- Reboot

- Clone the installer and start the installation

        $ sudo apt-get install git -y
        $ git clone https://github.com/mirakonta/Raspberry-PI-Link-Labs-LoRaWAN-Gateway.git ~/linklabs
        $ cd ~/linklabs
        $ sudo ./install.sh


# Credits

These scripts are largely based on the awesome work by [Ruud Vlaming](https://github.com/devlaam) on the [Lorank8 installer](https://github.com/Ideetron/Lorank).
