#!/bin/bash

# Ping test
if ping -c 2 1.1.1.1 >/dev/null 2>&1; then
	logger -p user.info -t connectivity "Network: OK (can reach 1.1.1.1)"
else
	logger -p user.error -t connectivity "Network: FAIL (cannot reach 1.1.1.1)"
	exit 1
fi

# DNS test
if getent hosts example.com >/dev/null 2>&1; then
	logger -p user.info -t connectivity "DNS: OK (example.com resolves)"
else
	logger -p user.error -t connectivity "DNS: FAIL (example.com does not resolve)"
fi

# Speed Test
if command -v speedtest-cli >/dev/null 2>&1; then
	logger -p user.info -t connectivity $(speedtest-cli --simple --secure)
else
	logger -p user.info -t connectivity "Speed test skipped (speedtest-cli not available)"
fi

