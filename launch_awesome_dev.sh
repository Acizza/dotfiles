#!/usr/bin/env bash

Xephyr :1 -ac -br -noreset -screen 2560x1440 & sleep 1
DISPLAY=:1 AWESOME_DEV=1 awesome --search $(nix eval --raw nixpkgs.luaPackages.luafilesystem)/lib/lua/5.2/
