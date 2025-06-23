#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Path to the .bluetooth.env file
ENV_FILE="$SCRIPT_DIR/.bluetooth.env"

# Source the environment file if it exists
if [ -f "$ENV_FILE" ]; then
    # shellcheck disable=SC1090
    source "$ENV_FILE"
else
    echo "Environment file $ENV_FILE not found."
    notify-send "Bluetooth Connect" "Missing .bluetooth.env file"
    exit 1
fi

forget_bluetooth() {
    echo "Checking connection status for $BT_MAC..."

    # If not connected, skip the logic
    if ! bluetoothctl info "$BT_MAC" 2>/dev/null | grep -q "Connected: yes"; then
        echo "Device $BT_MAC is already disconnected. Skipping removal."
        notify-send "Bluetooth Disconnect" "$BT_MAC is already disconnected"
        return 0
    fi

    echo "Disconnecting from $BT_MAC..."

    # Explicitly disconnect
    bluetoothctl disconnect "$BT_MAC" > /dev/null
    sleep 1

    # Then remove device
    bluetoothctl remove "$BT_MAC" > /dev/null
    sleep 1

    # Check again if still connected
    if bluetoothctl info "$BT_MAC" 2>/dev/null | grep -q "Connected: yes"; then
        echo "Device is still connected."
        notify-send "Bluetooth Disconnect" "Failed to disconnect from $BT_MAC"
        return 1
    else
        echo "Disconnected and removed $BT_MAC."
        notify-send "Bluetooth Disconnect" "Disconnected from $BT_MAC"
        return 0
    fi
}

pause_all_media() {
    echo "Pausing media players via playerctl..."
    playerctl --all-players pause 2>/dev/null
}

connect_bluetooth() {
    if [ -z "$BT_MAC" ]; then
        echo "BT_MAC is not set."
        notify-send "Bluetooth Connect" "BT_MAC variable is not set."
        return 1
    fi

    echo "Scanning for $BT_MAC..."
    bluetoothctl --timeout 10 scan on > /dev/null &
    sleep 10
    bluetoothctl scan off > /dev/null

    # Confirm device shows up in list
    if ! bluetoothctl devices | grep -q "$BT_MAC"; then
        echo "Could not detect device $BT_MAC during scan."
        notify-send "Bluetooth Connect" "Device $BT_MAC not found during scan."
        return 1
    fi

    echo "Pairing with $BT_MAC..."
    bluetoothctl pair "$BT_MAC" > /dev/null
    sleep 2

    if bluetoothctl info "$BT_MAC" | grep -q "Paired: yes"; then
        echo "Device is paired."
    else
        echo "Pairing failed."
        notify-send "Bluetooth Connect" "Pairing failed for $BT_MAC"
        return 1
    fi

    echo "Trusting $BT_MAC..."
    bluetoothctl trust "$BT_MAC" > /dev/null
    sleep 1

    if bluetoothctl info "$BT_MAC" | grep -q "Trusted: yes"; then
        echo "Device is trusted."
    else
        echo "Trusting failed."
        notify-send "Bluetooth Connect" "Trusting failed for $BT_MAC"
        return 1
    fi

    echo "Connecting to $BT_MAC..."
    bluetoothctl connect "$BT_MAC" > /dev/null
    sleep 2

    if bluetoothctl info "$BT_MAC" | grep -q "Connected: yes"; then
        echo "Connected to $BT_MAC."
        notify-send "Bluetooth Connect" "Connected, paired, and trusted $BT_MAC"
        return 0
    else
        echo "Failed to connect to $BT_MAC."
        notify-send "Bluetooth Connect" "Connection failed for $BT_MAC"
        return 1
    fi
}

# pause_all_media
# forget_bluetooth
connect_bluetooth
