#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

function link() {
	src="$SCRIPT_DIR/$1"
	dst=$2

	if [ ! -f $src ]; then
		echo "File $src does not exist"
		return 1
	fi

	if [ -f $dst ]; then
		echo "File $dst already exists"
		return 1
	fi

	echo "ln -s $dst $src"
	ln -s $src $dst
}

link vimrc ~/.vimrc
link zshrc ~/.zshrc

mkdir -p ~/.config/nvim
link init.vim ~/.config/nvim/init.vim

mkdir -p ~/.ssh
link ssh-agent-thing ~/.ssh-agent-thing
