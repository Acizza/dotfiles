#!/bin/sh

backgrounds=(~/backgrounds/active/*.{jpg,png})

rand=$[ $RANDOM % ${#backgrounds[@]} ]
exec feh --bg-scale ${backgrounds[$rand]}
