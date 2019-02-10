#!/usr/bin/env bash

MODE="boot"

if [ $# -ne 0 ]; then
    MODE=$1
fi

nixup --preupdate
sudo nixos-rebuild $MODE --upgrade --cores 0

echo "updated system packages:"
nixup