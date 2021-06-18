#!/bin/bash
cat <<EOF
server {
    listen       ${PORT} ssl http2 reuseport backlog=131072 fastopen=256;
    listen       [::]:${PORT} ssl http2 reuseport backlog=131072 fastopen=256;
    server_name  ${DOMAIN}
    add_header Allow "GET" always; 
    if ( \$request_method !~ ^(GET)$ ) {
		   return 444;
	}
    ssl_certificate ${TLS_CERT};
	ssl_certificate_key ${TLS_KEY};
	ssl_dhparam ${TLS_DHPARAM};
	ssl_session_cache shared:le_nginx_SSL:1m;
	ssl_session_cache shared:SSL:50m;
	ssl_session_timeout 1d;
	ssl_session_tickets off;
	ssl_protocols TLSv1.3 TLSv1.2;	
	ssl_ecdh_curve secp384r1;
	# ssl_early_data on;		
	add_header Content-Security-Policy "default-src https: data: 'unsafe-inline' 'unsafe-eval'" always;
	add_header Strict-Transport-Security 'max-age=63072000; includeSubdomains; preload' always;
	add_header X-Robots-Tag "noindex, nofollow" always;	
	add_header X-Content-Type-Options "nosniff" always;	
	add_header X-Xss-Protection "1; mode=block" always;
	resolver localhost valid=300s;
	ssl_buffer_size 8k;
	ssl_stapling on;
	ssl_stapling_verify on;
	ssl_prefer_server_ciphers on;
    ssl_trusted_certificate /etc/ssl/certs/ca-certificates.crt;
    root /wwwroot;
    location / {
        proxy_pass https://youtube.com;
		limit_rate 1000k;
		proxy_redirect off;
    }
    location ${QR_PATH} {
        root /wwwroot;
    }
    location = ${V2_PATH} {
        if (\$http_upgrade != "websocket") { # WebSocket return this when negotiation fails 404
            return 404;
        }
        proxy_redirect off;
        proxy_buffering off;
        proxy_pass http://127.0.0.1:2333;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$http_host;
    }
}
EOF
