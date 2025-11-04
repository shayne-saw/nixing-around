#!/usr/bin/env bash

set -e

cd "$(dirname "${BASH_SOURCE[0]}")/.."

if [ -f ./keycloak/ssl/cert.pem ]; then
  echo "✔ Setup already completed."
  exit 0
fi

echo -e "🔒 Setting up postgres data directory and initializing database..."
initdb -D ./postgres >/dev/null
echo -e "💾 Creating keycloak database and user..."
echo -e "💾 Creating application database and user..."

source ./bin/do-setup-neo4j.sh
source ./bin/do-setup-opensearch.sh

echo -e "📜 Creating SSL certificates for Keycloak..."
mkdir -p ./keycloak/ssl >/dev/null
pushd ./keycloak/ssl >/dev/null
openssl req -newkey rsa:2048 -x509 -nodes -days 365 -subj "/CN=localhost" \
  -keyout key.pem -out cert.pem >/dev/null
popd >/dev/null

echo -e "💖 Set up has completed! Run process-compose up to see the magic ✨"
