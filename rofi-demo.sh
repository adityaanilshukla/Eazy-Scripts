
#!/bin/bash

# Simple rofi menu demo

chosen=$(echo -e "Say Hello\nShow Date\nLaunch Terminal" | rofi -dmenu -i -p "Choose:")

case "$chosen" in
    "Say Hello")
        notify-send "Hello from Rofi!" ;;
    "Show Date")
        notify-send "Current date:" "$(date)" ;;
    "Launch Terminal")
        i3-sensible-terminal ;;
esac
