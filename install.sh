#!/bin/sh

sudo apt update
sudo apt install -y python3 git

curl https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py
python3 /tmp/get-pip.py --user
python3 -m pip install --user ansible

git clone git@github.com:joao-fnunes/dotfiles.git

cd dotfiles

make bootstrap
make install
