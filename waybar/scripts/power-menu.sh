#!/bin/bash
entries="󰗽 Logout\n⏾ Suspend\n󰜉 Reboot\n⏻ Shutdown\n Lock"

selected=$(echo -e "$entries" | wofi --dmenu --prompt "Power" --no-animations | awk '{print $2}')

case $selected in
    Logout)
        hyprctl dispatch exit ;;
    Suspend)
        systemctl suspend ;;
    Reboot)
        systemctl reboot ;;
    Shutdown)
        systemctl poweroff ;;
    Lock)
        loginctl lock-session ;;
esac
