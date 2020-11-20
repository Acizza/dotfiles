#!/usr/bin/env bash

unknown_flag() {
    echo "unknown flag: $1"
    echo
    echo "flag combos:"
    echo " l - Laptop"
    echo " p - Raspberry-Pi media"
    echo " u - Unmount"
}

LOCATION=""

while read -n1 char; do
    case $char in
        l)
            LOCATION="wendy@w.laptop:/"
            ;;
        p)
            LOCATION="pi@rasp.pi:/media"
            ;;
        u)
            fusermount -u /mnt
            exit 0
            ;;
        *)
            unknown_flag $char
            exit 1
            ;;
    esac
done < <(echo -n "$1")

exec sshfs "$LOCATION" -o allow_other,reconnect,ServerAliveInterval=15,ServerAliveCountMax=3 /mnt
