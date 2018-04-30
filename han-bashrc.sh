#!/bin/bash

set -e

function getSetting() {
    if [ -e ~/bashrc ]; then
        curl -fsSLo ~/.bashrc https://raw.githubusercontent.com/ko-han/han-bashrc/master/.bashrc
    else
        curl -fsSL https://raw.githubusercontent.com/ko-han/han-bashrc/master/.bashrc >> ~/.bashrc
    fi
    if [ -e ~/bash_alias ]; then
        curl -fsSLo ~/.bash_alias https://raw.githubusercontent.com/ko-han/han-bashrc/master/.bash_alias
    else
        curl -fsSL https://raw.githubusercontent.com/ko-han/han-bashrc/master/.bash_alias >> ~/.bash_alias
    fi
}


echo "--------------- han-bashrc ----------------"
echo
if [ -e ~/.bashrc ]; then
read -r -p "Do you want delete '~/.bashrc'(default No)?[Y/N] " input
case $input in
    [yY][eE][sS]|[yY])
        rm ~/.bashrc
        ;;
    *)
        ;;
esac
fi
if [ -e ~/.bash_alias ]; then
read -r -p "Do you want delete '~/.bash_alias'(default No)?[Y/N] " input
case $input in
    [yY][eE][sS]|[yY])
        rm ~/.bash_alias
        ;;
    *)
        ;;
esac
fi

getSetting

read -r -p "Activate now(default No)?[Y/N] " input
case $input in
    [yY][eE][sS]|[yY])
        [ -e ~/.bashrc ] && . ~/.bashrc
        ;;
    *)
        ;;
esac

