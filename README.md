# Wireguard-SIP-Proxy

SIP B2BUA with Asterisk in Docker, where the upstream SIP trunk is only reached through WireGuard.

Call path:

PBX -> Asterisk (this container) -> real SIP trunk

Asterisk handles:
- SIP trunk authentication
- SIP signaling and RTP anchoring
- header handling (including `P-Asserted-Identity`)

The real SIP trunk sees the public IP of your WireGuard egress peer.

## What this repository provides

- A Docker image with WireGuard and Asterisk
- A startup script that:
  - brings up `wg0`
  - auto-creates `pjsip.conf` and `extensions.conf` from sample files if needed
  - starts Asterisk in foreground
- sample configs for:
  - PJSIP trunking (`config/asterisk:/pjsip.sample.conf`)
  - dialplan routing (`config/asterisk:/extensions.sample.conf`)
  - WireGuard (`config/wireguard/wg0.sample.conf`)

## 1. Prepare config files

### Asterisk

1. Copy and edit:
	- `config/asterisk:/pjsip.sample.conf` -> `config/asterisk:/pjsip.conf`
	- `config/asterisk:/extensions.sample.conf` -> `config/asterisk:/extensions.conf`
2. In `pjsip.conf`, set these placeholders:
	- `YOUR_PBX_IP`
	- `YOUR_PBX_TRUNK_USER`
	- `YOUR_PBX_TRUNK_PASSWORD`
	- `REAL_TRUNK_FQDN_OR_IP`
	- `REAL_TRUNK_USERNAME`
	- `REAL_TRUNK_PASSWORD`
	- `REAL_TRUNK_IP_OR_SBC_IP`

### WireGuard

1. Copy and edit:
	- `config/wireguard/wg0.sample.conf` -> `config/wireguard/wg0.conf`
2. Replace placeholders:
	- `<CLOUD_PRIVATE_KEY>`
	- `<EGRESS_PEER_PUBLIC_KEY>`
	- `<EGRESS_PEER_PUBLIC_IP>`
	- `<REAL_TRUNK_SIGNALING_IP>/32`
	- `<REAL_TRUNK_RTP_NET_CIDR>`

Important: `AllowedIPs` must include the real trunk signaling and RTP destination ranges so traffic is forced through `wg0`.

## 2. Start

```bash
docker compose up -d --build
```

Logs:

```bash
docker compose logs -f wireguard-sip-proxy
```

## 3. Verify call path and routing

Open Asterisk CLI:

```bash
docker exec -it wireguard-sip-proxy asterisk -rvvv
```

Useful checks:

```asterisk
pjsip show registrations
pjsip show endpoints
dialplan show from-pbx
dialplan show from-realtrunk
```

WireGuard and routes in container:

```bash
docker exec -it wireguard-sip-proxy sh -c "wg show && ip route"
```

## Header and media behavior

- `direct_media=no` keeps media anchored on Asterisk (B2BUA behavior)
- `send_pai=yes` and `trust_id_outbound=yes` allow PAI forwarding
- dialplan subroutine `add-pai` forwards incoming `P-Asserted-Identity` or builds one from caller ID

If your provider requires strict identity format, adjust the `add-pai` context in `extensions.conf`.

## Ports

- SIP: UDP 5060
- RTP: UDP 10000-10100

## Notes

- This project currently uses only UDP SIP in the sample config.
- If your PBX and provider require TCP/TLS, add dedicated transports and endpoint settings in `pjsip.conf`.
