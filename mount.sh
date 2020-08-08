#!/usr/bin/env bash

unknown_flag() {
    echo "unknown flag: $1"
    echo
    echo "flag combos:"
    echo " l - Laptop"
    echo " p - Raspberry-Pi media"
    echo " u - Unmount"
}

while read -n1 char; do
    case $char in
        l)
            sshfs wendy@w.laptop -o allow_other /mnt
            ;;
        p)
            sshfs pi@rasp.pi:/media -o allow_other /mnt
            ;;
        u)
            fusermount -u /mnt
            ;;
        *)
            unknown_flag $char
            exit 1
            ;;
    esac
done < <(echo -n "$1")