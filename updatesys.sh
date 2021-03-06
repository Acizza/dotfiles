#!/usr/bin/env bash

MODE="boot"

if [ $# -ne 0 ]; then
    MODE=$1
fi

nixup -s

sudo nixos-rebuild $MODE --upgrade --cores 12

printf "\n"
nixup
