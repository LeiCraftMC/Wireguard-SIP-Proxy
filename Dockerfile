FROM alpine:latest

# Install WireGuard, Asterisk, and routing tools
RUN apk add --no-cache \
    wireguard-tools \
    asterisk \
    asterisk-sample-config \
    iproute2 \
    curl

# Copy your configuration files
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

VOLUME /etc/asterisk
VOLUME /etc/wireguard

# SIP and RTP ports
EXPOSE 5060/udp 10000-10100/udp

ENTRYPOINT ["/entrypoint.sh"]