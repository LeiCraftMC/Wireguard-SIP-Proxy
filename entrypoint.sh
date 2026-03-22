#!/bin/sh

set -eu

# Function to handle shutdown
cleanup() {
    echo "Shutting down WireGuard..."
    wg-quick down wg0 || true
    exit 0
}

# Trap termination signals
trap cleanup SIGINT SIGTERM

echo "Preparing Asterisk configuration..."
if [ ! -f "/etc/asterisk/pjsip.conf" ] && [ -f "/etc/asterisk/pjsip.sample.conf" ]; then
    cp /etc/asterisk/pjsip.sample.conf /etc/asterisk/pjsip.conf
    echo "Created /etc/asterisk/pjsip.conf from sample file."
fi

if [ ! -f "/etc/asterisk/extensions.conf" ] && [ -f "/etc/asterisk/extensions.sample.conf" ]; then
    cp /etc/asterisk/extensions.sample.conf /etc/asterisk/extensions.conf
    echo "Created /etc/asterisk/extensions.conf from sample file."
fi

if [ ! -f "/etc/asterisk/pjsip.conf" ]; then
    echo "Error: /etc/asterisk/pjsip.conf not found."
    echo "Provide config/asterisk:/pjsip.conf or pjsip.sample.conf in your bind mount."
    exit 1
fi

if [ ! -f "/etc/asterisk/extensions.conf" ]; then
    echo "Error: /etc/asterisk/extensions.conf not found."
    echo "Provide config/asterisk:/extensions.conf or extensions.sample.conf in your bind mount."
    exit 1
fi

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

echo "WireGuard status:"
wg show || true

echo "Starting Asterisk..."
# -f: foreground, -v: verbose, -p: high priority
exec asterisk -f -vvv
