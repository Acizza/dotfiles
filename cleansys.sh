#!/usr/bin/env bash

printf "!! removing unused store paths\n\n"
sudo nix-collect-garbage --delete-older-than 14d

printf "\n!! optimizing store\n\n"
sudo nix-store --optimise
