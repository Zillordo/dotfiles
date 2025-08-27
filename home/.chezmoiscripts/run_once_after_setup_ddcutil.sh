#!/bin/bash

echo i2c-dev | sudo tee /etc/modules-load.d/i2c-dev.conf
sudo groupadd -f i2c-stub-from-dump
sudo usermod -aG i2c "$USER"

sudo chmod +x ~/.config/hypr/scripts/brightness.nu
