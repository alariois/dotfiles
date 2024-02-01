#!/bin/bash

# to open with shortcut, add custom shortcut and type command:
# gnome-terminal -- bash -c '~/scripts/nvim_clipboard.sh'
# or
# xterm -e '~/scripts/nvim_clipboard.sh'
# etc
#
# Shift + Alt + W


xclip -se c -o | nvim -
