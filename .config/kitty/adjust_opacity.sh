#!/bin/bash

# Path to your kitty.conf
KITTY_CONF=~/.config/kitty/kitty.conf

# Amount to adjust opacity by
ADJUSTMENT=$1

# Read the current opacity
CURRENT_OPACITY=$(grep '^background_opacity' $KITTY_CONF | tail -1 | awk '{print $2}')

# Calculate new opacity
NEW_OPACITY=$(echo "$CURRENT_OPACITY + $ADJUSTMENT" | bc)

# Ensure new opacity is within [0,1]
if (( $(echo "$NEW_OPACITY < 0" | bc -l) )); then
    NEW_OPACITY=0
elif (( $(echo "$NEW_OPACITY > 1" | bc -l) )); then
    NEW_OPACITY=1
fi

# Replace the old opacity value with the new one in kitty.conf
sed -i "/^background_opacity/c\background_opacity $NEW_OPACITY" $KITTY_CONF

# Reload kitty configuration
kitty @ load-config
