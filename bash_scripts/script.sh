#!/bin/bash

sudo apt update
sudo apt upgrade

sudo apt install python3 python3-pip -y
python3 --version
pip3 --version

sudo apt install python3-venv -y

python3 -m venv ansible_env
source ansible_env/bin/activate

pip3 install ansible

ansible --version

pip3 install --upgrade ansible

deactivate