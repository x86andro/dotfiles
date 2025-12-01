#!/usr/bin/env bash

if ip link | grep -q 'state UP'; then
    if ! ping -q -c 1 -W 1 1.1.1.1 > /dev/null; then
        echo '{"text": "[no internet]", "tooltip": "No internet access", "class": "no-internet"}'
    fi
fi
