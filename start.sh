#! /bin/bash

# Reset PIN
gpio -1 mode 29 out
gpio -1 write 29 0
sleep 0.1
gpio -1 write 29 1
sleep 0.1
gpio -1 write 29 0
sleep 0.1

# Test the connection, wait if needed.
while [[ $(ping -c1 google.com 2>&1 | grep " 0% packet loss") == "" ]]; do
  echo "[LoRa Gateway]: Waiting for internet connection..."
  sleep 30
  done

# Fire up the forwarder.
/opt/linklabs/bin/gps_pkt_fwd
