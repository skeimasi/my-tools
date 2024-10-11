#!/bin/bash

# Define the DNS server sets
DNS_403="10.202.10.202,10.202.10.102"
DNS_SHEKAN="178.22.122.100,185.51.200.2"
DNS_GOOGLE="8.8.8.8,8.8.4.4"
DNS_CLOUDFLARE="1.1.1.1,1.0.0.1"
DNS_SHCAN="178.22.122.100,185.51.200.2"
DNS_COMODO="8.26.56.26,8.20.247.20"
DNS_OPENDNS="208.67.222.222,208.67.220.220"
DNS_QUAD9="9.9.9.9,149.112.112.112"
DNS_VERISIGN="64.6.64.6,64.6.65.6"

# Set Zenity window dimensions
WINDOW_WIDTH=600
WINDOW_HEIGHT=400

# Display a menu for DNS selection with increased width and height
DNS_CHOICE=$(zenity --list --radiolist --title="Select DNS Configuration" \
    --column="Select" --column="Option" \
    TRUE "403: $DNS_403" \
    FALSE "Shekan: $DNS_SHEKAN" \
    FALSE "Google: $DNS_GOOGLE" \
    FALSE "Cloudflare: $DNS_CLOUDFLARE" \
    FALSE "Shcan: $DNS_SHCAN" \
    FALSE "Comodo Secure: $DNS_COMODO" \
    FALSE "OpenDNS: $DNS_OPENDNS" \
    FALSE "Quad9: $DNS_QUAD9" \
    FALSE "Verisign: $DNS_VERISIGN" \
    --width=$WINDOW_WIDTH --height=$WINDOW_HEIGHT)

# Check which DNS was selected
case "$DNS_CHOICE" in
    "403: $DNS_403")
        SELECTED_DNS=$DNS_403
        ;;
    "Shekan: $DNS_SHEKAN")
        SELECTED_DNS=$DNS_SHEKAN
        ;;
    "Google: $DNS_GOOGLE")
        SELECTED_DNS=$DNS_GOOGLE
        ;;
    "Cloudflare: $DNS_CLOUDFLARE")
        SELECTED_DNS=$DNS_CLOUDFLARE
        ;;
    "Shcan: $DNS_SHCAN")
        SELECTED_DNS=$DNS_SHCAN
        ;;
    "Comodo Secure: $DNS_COMODO")
        SELECTED_DNS=$DNS_COMODO
        ;;
    "OpenDNS: $DNS_OPENDNS")
        SELECTED_DNS=$DNS_OPENDNS
        ;;
    "Quad9: $DNS_QUAD9")
        SELECTED_DNS=$DNS_QUAD9
        ;;
    "Verisign: $DNS_VERISIGN")
        SELECTED_DNS=$DNS_VERISIGN
        ;;
    *)
        zenity --error --text="Invalid choice. Exiting."
        exit 1
        ;;
esac

# Get a list of available connections
CONNECTIONS=$(nmcli -t -f NAME connection show)
CONNECTION_ARRAY=($CONNECTIONS)

# Generate options string for Zenity list
OPTIONS=""
for i in "${!CONNECTION_ARRAY[@]}"; do
  OPTIONS+="$((i + 1)) ${CONNECTION_ARRAY[$i]} "
done

# Display connections as a menu with increased width and height
CONNECTION_CHOICE=$(zenity --list --title="Select Network Connection" \
    --column="Number" --column="Connection Name" \
    --width=600 --height=400 \
    $OPTIONS)

# Check if the user selection is valid
if [[ "$CONNECTION_CHOICE" =~ ^[0-9]+$ && "$CONNECTION_CHOICE" -gt 0 && "$CONNECTION_CHOICE" -le "${#CONNECTION_ARRAY[@]}" ]]; then
  CONNECTION_NAME=${CONNECTION_ARRAY[$((CONNECTION_CHOICE - 1))]}
else
  zenity --error --text="Invalid connection choice. Exiting."
  exit 1
fi

# Apply the new DNS servers to the specified connection
nmcli connection modify "$CONNECTION_NAME" ipv4.dns "$SELECTED_DNS"

# Turn off automatic DNS
nmcli connection modify "$CONNECTION_NAME" ipv4.ignore-auto-dns yes

# Restart the network connection to apply changes
nmcli connection down "$CONNECTION_NAME"
nmcli connection up "$CONNECTION_NAME"

zenity --info --text="DNS settings updated to $SELECTED_DNS_NAME ($SELECTED_DNS) and connection restarted for $CONNECTION_NAME."
# zenity --info --text="DNS settings updated and connection restarted for $CONNECTION_NAME."
