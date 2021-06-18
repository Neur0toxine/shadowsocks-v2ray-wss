#!/bin/bash

if [[ -z "${PASSWORD}" ]]; then
  export PASSWORD="B1922A0B-1D77-40C6-8119-497AB81BC7A4"
  echo WARNING: Default password is being used! Please replace default password with you own.
fi

export PASSWORD_JSON="$(echo -n "$PASSWORD" | jq -Rc)"

if [[ -z "${ENCRYPT}" ]]; then
  export ENCRYPT="xchacha20-ietf-poly1305"
fi

if [[ -z "${V2_PATH}" ]]; then
  export V2_PATH="/v2ray"
fi

if [[ -z "${QR_PATH}" ]]; then
  export QR_PATH="/qr_code"
fi

if [[ -z "${GENERATE_QR}" ]]; then
  export GENERATE_QR="yes"
fi

if [[ -z "${PORT}" ]]; then
  export PORT="443"
fi

if [[ -z "${DOMAIN}" ]]; then
  export DOMAIN="localhost"
fi

if [[ -z "${DNS_SERVERS}" ]]; then
  export DNS_SERVERS="1.1.1.1,1.0.0.1"
fi

if [[ -z "${TLS_CERT}" ]]; then
  export TLS_CERT="/etc/ssl/ssl.pem"
fi

if [[ -z "${TLS_KEY}" ]]; then
  export TLS_KEY="/etc/ssl/ssl.key"
fi

if [[ -z "${TLS_DHPARAM}" ]]; then
  export TLS_DHPARAM="/etc/ssl/dhparams.pem"
fi

echo Proxy domain: ${DOMAIN}
echo Proxy port: ${PORT}
echo Proxy password: ${PASSWORD}
echo Encryption: ${ENCRYPT}
echo TLS certificate path: ${TLS_CERT}
echo TLS private key path: ${TLS_KEY}
echo dhparams path: ${TLS_DHPARAM}
echo Path to V2Ray: ${V2_PATH}
echo Path to QR code page: ${QR_PATH}
echo Generate QR code: ${GENERATE_QR}

if [[ ! -f "${TLS_DHPARAM}" ]]; then
  echo Cannot find existing dhparams.pem, it will be generated now.
  openssl dhparam -out "${TLS_DHPARAM}" 4096
fi

if ! id www-data &>/dev/null; then
    adduser -s /bin/false -S -D -H www-data
fi

if ! id shadowsocks &>/dev/null; then
    adduser -s /bin/false -S -D -H shadowsocks
fi

bash /config/shadowsocks-libev_config.json.sh > /etc/shadowsocks-libev/config.json
echo /etc/shadowsocks-libev/config.json has been updated with following contents:
cat /etc/shadowsocks-libev/config.json
echo

mkdir -p /etc/nginx/conf.d
mv /config/nginx.conf /etc/nginx/nginx.conf
bash /config/nginx_ss.conf.sh > /etc/nginx/conf.d/ss.conf
echo /etc/nginx/conf.d/ss.conf has been updated with following contents:
cat /etc/nginx/conf.d/ss.conf
echo

if [[ "$GENERATE_QR" = "yes" ]]; then
  [ ! -d /wwwroot/${QR_PATH} ] && mkdir /wwwroot/${QR_PATH}
  plugin=$(echo -n "v2ray;path=${V2_PATH};host=${DOMAIN};tls;fast-open" | sed -e 's/\//%2F/g' -e 's/=/%3D/g' -e 's/;/%3B/g')
  ss="ss://$(echo -n ${ENCRYPT}:${PASSWORD} | base64 -w 0)@${DOMAIN}:${PORT}?plugin=${plugin}" 
  echo "<!DOCTYPE html><html><head><title>Shadowsocks Account</title></head><body>" > /wwwroot/${QR_PATH}/index.html
  echo "<p>${ss}</p>" | tr -d '\n' >> /wwwroot/${QR_PATH}/index.html
  echo "<img src=\"${QR_PATH}/vpn.png\">" >> /wwwroot/${QR_PATH}/index.html
  echo "</body></html>" >> /wwwroot/${QR_PATH}/index.html
  echo -n "${ss}" | qrencode -s 6 -o /wwwroot/${QR_PATH}/vpn.png
fi

chown www-data:www-data -R /wwwroot
echo Running nginx and shadowsocks proxy...

sudo -u shadowsocks ss-server -c /etc/shadowsocks-libev/config.json &
rm -rf /etc/nginx/sites-enabled/default
nginx -g 'daemon off;'
