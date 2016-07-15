#!/bin/bash

# Stop on the first sign of trouble
set -e

if [ $UID != 0 ]; then
    echo "ERROR: Operation not permitted. Forgot sudo?"
    exit 1
fi

echo "Link Labs Gateway installer"

# Update the gateway installer to the correct branch
echo "Updating installer files..."
VERSION="spi"
OLD_HEAD=$(git rev-parse HEAD)
git fetch
git checkout -q $VERSION
git pull
NEW_HEAD=$(git rev-parse HEAD)

if [[ $OLD_HEAD != $NEW_HEAD ]]; then
    echo "New installer found. Restarting process..."
    exec "./install.sh"
fi

# Check dependencies
echo "Installing dependencies..."
sudo apt-get install swig python-dev -y
sudo apt-get install WiringPi -y
sudo apt-get install Git -y

# Install LoRaWAN packet forwarder repositories
INSTALL_DIR="/opt/linklabs"
if [ ! -d "$INSTALL_DIR" ]; then mkdir $INSTALL_DIR; fi
pushd $INSTALL_DIR

# Build LoRa gateway app
if [ ! -d lora_gateway ]; then
    git clone --branch v3.2.1 https://github.com/Lora-net/lora_gateway.git
    pushd lora_gateway
else
    pushd lora_gateway
    git reset --hard
    git pull
fi

sed -i 's/cs_change = 1/cs_change = 0/g' libloragw/src/loragw_spi.native.c

make

popd

# Build packet forwarder
if [ ! -d packet_forwarder ]; then
    git clone --branch v2.2.1 https://github.com/Lora-net/packet_forwarder.git
    pushd packet_forwarder
else
    pushd packet_forwarder
    git pull
    git reset --hard
fi

make

popd

# Symlink
if [ ! -d bin ]; then mkdir bin; fi
if [ -f ./bin/basic_pkt_fwd ]; then rm ./bin/basic_pkt_fwd; fi
if [ -f ./bin/beacon_pkt_fwd ]; then rm ./bin/beacon_pkt_fwd; fi
if [ -f ./bin/gps_pkt_fwd ]; then rm ./bin/gps_pkt_fwd; fi
ln -s $INSTALL_DIR/packet_forwarder/basic_pkt_fwd/basic_pkt_fwd ./bin/basic_pkt_fwd
ln -s $INSTALL_DIR/packet_forwarder/beacon_pkt_fwd/beacon_pkt_fwd ./bin/beacon_pkt_fwd
ln -s $INSTALL_DIR/packet_forwarder/gps_pkt_fwd/gps_pkt_fwd ./bin/gps_pkt_fwd
cp -f ./packet_forwarder/gps_pkt_fwd/global_conf.json ./bin/global_conf.json

# Reset gateway ID based on MAC
./packet_forwarder/reset_pkt_fwd.sh start ./bin/local_conf.json

popd

echo "Installation completed."

# Start packet forwarder as a service
cp ./start.sh $INSTALL_DIR/bin/
cp ./linklabs.service /etc/systemd/system/
systemctl enable linklabs.service

echo "The system will reboot in 5 seconds..."
sleep 5
shutdown -r now
