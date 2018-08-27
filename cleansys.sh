#!/usr/bin/env bash

DELETE_OLD_GENERATIONS=false

while getopts ":d" opt; do
    case $opt in
        d)
            DELETE_OLD_GENERATIONS=true
            ;;
        \?)
            echo "unknown option: -$OPTARG" >&2
            ;;
    esac
done

printf "!! removing unused store paths\n\n"
sudo nix-collect-garbage

if [ "$DELETE_OLD_GENERATIONS" = true ]; then
    printf "\n!! removing old store generations\n\n"
    sudo nix-collect-garbage -d
fi

printf "\n!! optimizing store\n\n"
sudo nix-store --optimise