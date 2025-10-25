#!/bin/bash
while true; do
    clear
    printf "\n%62s" "" && figlet "Arch Linux" | lolcat
    sleep 1
    if [ -z "$(jobs)" ]; then
        break
    fi
done

