#!/bin/sh

backgrounds=(~/backgrounds/active/*.{jpg,png})

rand=$[ $RANDOM % ${#backgrounds[@]} ]
background=${backgrounds[$rand]}

feh --bg-scale $background
wal -q -n -i $background
