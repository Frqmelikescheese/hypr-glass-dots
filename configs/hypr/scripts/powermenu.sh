
#!/bin/bash

# Simple powermenu using Rofi

OPTIONS="Shutdown
Reboot
Logout"
CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu -p "Power Menu")

case "$CHOICE" in
    "Shutdown")
        systemctl poweroff
        ;;
    "Reboot")
        systemctl reboot
        ;;
    "Logout")
        hyprctl dispatch exit
        ;;
esac
