#!/usr/bin/env bash

MODE="switch"

if [ $# -ne 0 ]; then
    MODE=$1
fi

sudo nixos-rebuild $MODE --upgrade --cores 0