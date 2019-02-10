#!/usr/bin/env bash

MODE="boot"

if [ $# -ne 0 ]; then
    MODE=$1
fi

sudo nixos-rebuild $MODE --upgrade --cores 0