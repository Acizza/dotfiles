#!/usr/bin/env bash

FILES=(~/backgrounds/active/*.{png,jpg})
IDX=$(( $RANDOM % ${#FILES[@]} ))

wal -q -i "${FILES[$IDX]}"
feh --bg-scale ${FILES[$IDX]}