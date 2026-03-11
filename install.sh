#!/bin/sh

source /etc/os-release

if [[ $ID == "arch" ]]; then
  sudo pacman -Sy python3 python3-pip ansible git make
elif [[ $ID == "ubuntu" ]]
  sudo apt update
  sudo apt install -y python3 python3-pip ansible git make
else
  echo "Unknown distro"
  exit 1
fi

git clone https://github.com/joao-fnunes/dotfiles.git

cd dotfiles

make bootstrap && make install
