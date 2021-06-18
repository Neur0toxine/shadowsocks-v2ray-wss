#!/bin/bash
cat <<EOF
{
    "server": "127.0.0.1",
    "server_port": "2333",
    "password": ${PASSWORD_JSON},
    "timeout": 300,
    "method": "${ENCRYPT}",
    "mode": "tcp_only",
    "fast_open": true,
    "nameserver": "${DNS_SERVERS}",
    "reuse_port": true,
    "no_delay": true,
    "plugin": "v2ray-plugin",
    "plugin_opts": "server;path=${V2_PATH};loglevel=none"
}
EOF