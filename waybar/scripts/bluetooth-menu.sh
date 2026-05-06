#!/bin/bash
# Bluetooth device manager using bluetoothctl + wofi
# Shows paired/trusted devices, toggles connection

# Get list of paired (trusted) devices with MAC and alias
devices=$(bluetoothctl devices Paired | while read -r mac alias; do
    # Check if currently connected
    connected=$(bluetoothctl info "$mac" | grep "Connected: yes")
    if [[ -n "$connected" ]]; then
        echo "󰂱 $alias - connected"
    else
        echo "󰂯 $alias"
    fi
done)

# Add option to enable/disable Bluetooth itself
menu=" Enable Bluetooth (scan on)\n Disable Bluetooth\n$devices"

selected=$(echo -e "$menu" | wofi --dmenu --prompt "Bluetooth" --no-animations)

case "$selected" in
    *"Enable Bluetooth"*)
        rfkill unblock bluetooth
        bluetoothctl power on
        bluetoothctl scan on &
        sleep 3
        kill %1 ;;
    *"Disable Bluetooth"*)
        bluetoothctl power off ;;
    *"connected"*)
        # Extract alias from line (remove status)
        alias=$(echo "$selected" | sed 's/ - connected//' | xargs)
        # Get MAC from alias
        mac=$(bluetoothctl devices Paired | grep "$alias" | awk '{print $2}')
        bluetoothctl disconnect "$mac" ;;
    *"󰂯 "*)
        alias=$(echo "$selected" | sed 's/󰂯 //' | xargs)
        mac=$(bluetoothctl devices Paired | grep "$alias" | awk '{print $2}')
        bluetoothctl connect "$mac" ;;
esac
