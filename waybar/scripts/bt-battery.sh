#!/bin/bash
# Output: icon, device name, and battery % (if available)

# Check if Bluetooth is enabled
if ! bluetoothctl show | grep -q "Powered: yes"; then
    echo '{"text": " off", "class": "disabled"}'
    exit
fi

# Find the first connected device
connected_mac=$(bluetoothctl info | grep "Connected: yes" -B1 | head -1 | awk '{print $2}')
if [[ -z "$connected_mac" ]]; then
    echo '{"text": " --", "class": "disconnected"}'
    exit
fi

alias=$(bluetoothctl info "$connected_mac" | grep "Alias" | cut -d ' ' -f2-)
# Try to get battery from bluetoothctl (works for many headsets)
battery=$(bluetoothctl info "$connected_mac" | grep "Battery Percentage" | awk '{print $NF}' | tr -d '()%')
# Fallback: try upower (for some headsets)
if [[ -z "$battery" ]]; then
    battery=$(upower -i /org/freedesktop/UPower/devices/headset_dev* 2>/dev/null | grep percentage | awk '{print $2}' | tr -d '%')
fi

if [[ -n "$battery" ]]; then
    text=" $alias  $battery%"
else
    text=" $alias"
fi

echo "{\"text\": \"$text\", \"class\": \"connected\"}"
