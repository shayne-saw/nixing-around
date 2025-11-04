# Keycloak with Self-Signed SSL Certificate

```bash
mkdir -p keycloak/ssl
```

Generate the self-signed SSL certificate

```bash
openssl req -newkey rsa:2048 -nodes -keyout key.pem -x509 -days 365 -out cert.pem -subj "/CN=localhost"
```

Enter the keycloak FHS bubble

```bash
keycloak-env
```

Start the keycloak server

```bash
kc.sh start --optimized \
  --https-certificate-file="$PWD/keycloak/ssl/cert.pem" \
  --https-certificate-key-file="$PWD/keycloak/ssl/key.pem" \
  --https-port=8443 \
  --hostname=localhost
```
```

