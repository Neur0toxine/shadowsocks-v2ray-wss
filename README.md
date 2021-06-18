# Shadowsocks + V2Ray in Docker

Preconfigured solution for running Shadowsocks proxy with V2Ray inside Docker container.
You'll need a working domain for this solution.

Usage:

1. Copy `.env.dist` to `.env`
2. Replace demo values with your own (especially password).
3. Add your domain certificate to the `cert.pem` file.
4. Add your domain private key to the `cert.key` file.
5. Generate dhparams.pem using command `openssl dhparam -out "${TLS_DHPARAM}" 4096` or just remove like `- ./dhparams.pem:${TLS_DHPARAM}` from the `docker-compose.yml`.
6. Run `docker-compose up -d`.
