#!/usr/bin/env bash

yay -Syu

if [ $? == 0 ]; then
    printf "\n!! removing unused locales\n\n"
    sudo localepurge

    printf "!! removing cached package files\n\n"
    sudo paccache -rvk 0
fi
