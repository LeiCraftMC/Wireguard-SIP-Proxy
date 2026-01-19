#!/bin/bash
# Start WireGuard
wg-quick up wg0

# Route all Telekom IP ranges through WireGuard
# 217.0.0.0/13 is the main one, adding 80.128.0.0/10 for safety
#ip route add 217.0.0.0/13 dev wg0
#ip route add 80.128.0.0/10 dev wg0

# Start Asterisk in the foreground
asterisk -f
