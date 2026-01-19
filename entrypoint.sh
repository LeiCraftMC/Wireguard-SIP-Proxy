#!/bin/sh

# Function to handle shutdown
cleanup() {
    echo "Shutting down WireGuard..."
    wg-quick down wg0
    exit 0
}

# Trap termination signals
trap cleanup SIGINT SIGTERM

echo "Starting WireGuard..."
# Ensure the config file exists before trying to start
if [ -f "/etc/wireguard/wg0.conf" ]; then
    wg-quick up wg0
else
    echo "Error: /etc/wireguard/wg0.conf not found!"
    exit 1
fi

# Optional: verify the route
echo "Current routing table:"
ip route

echo "Starting Asterisk..."
# -f: foreground, -v: verbose, -p: high priority
exec asterisk -f -vvv
