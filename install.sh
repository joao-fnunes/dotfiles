#!/bin/sh

source /etc/os-release

if [[ $ID == "arch" ]]; then
	sudo pacman -Sy python3 git make
else
	sudo apt update
	sudo apt install -y python3 python3-distutils git make
fi

curl https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py
python3 /tmp/get-pip.py --user
python3 -m pip install --user ansible

git clone https://github.com/joao-fnunes/dotfiles.git

cd dotfiles

export PATH="/home/$USER/.local/bin:$PATH"
make bootstrap && make install
