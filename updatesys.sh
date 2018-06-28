#!/usr/bin/env bash

yay -Syu

if [ $? == 0 ]; then
    printf "\n!! removing unused locales\n\n"
    sudo localepurge

    printf "!! removing cached package files\n\n"
    sudo paccache -rvk 0

    printf "!! detecting unneeded packages\n\n"
    sudo pacman -Rcuns $(pacman -Qtdq)
fi
