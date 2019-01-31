#!/usr/bin/env bash

# Needed for XAudio libraries (xact doesn't provide the correct ones)
winetricks directx9

# Despite tricking UE4 to use an older version of this library, it seems to work perfectly
ln -s "$WINEPREFIX"/drive_c/windows/system32/XAPOFX1_4.dll "$WINEPREFIX"/drive_c/windows/system32/XAPOFX1_5.dll
