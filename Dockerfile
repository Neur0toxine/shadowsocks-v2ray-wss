FROM alpine:latest

ARG V2RAY_VERSION=v1.3.1

RUN set -ex \
    && apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing wget libqrencode shadowsocks-libev nginx jq bash sudo \
    && mkdir -p /etc/shadowsocks-libev /v2raybin /wwwroot \
    && wget -O- "https://github.com/shadowsocks/v2ray-plugin/releases/download/${V2RAY_VERSION}/v2ray-plugin-linux-amd64-${V2RAY_VERSION}.tar.gz" | \
    tar zx -C /v2raybin \
    && install /v2raybin/v2ray-plugin_linux_amd64 /usr/bin/v2ray-plugin \
    && rm -rf /v2raybin

COPY config/ /config
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

CMD /entrypoint.sh
