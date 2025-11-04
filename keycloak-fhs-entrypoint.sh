#!/usr/bin/env bash

export KC_HOME_DIR="$PWD/keycloak"
export KC_CONF_DIR="$KC_HOME_DIR/conf"

REAL_KEYCLOAK_BIN="$(readlink -f "$(command -v kc.sh)")"
KEYCLOAK_DIST_DIR="$(dirname "$(dirname "$REAL_KEYCLOAK_BIN")")"

mkdir -p "${KC_HOME_DIR}"/{data,log,tmp}

# Copy default config if missing
if [ ! -d keycloak/conf ]; then
  cp -r "${KEYCLOAK_DIST_DIR}/conf/" keycloak/
  chmod -R u+w keycloak/conf/
  cp keycloak/conf/keycloak.conf cassandra/conf/keycloak.conf.original
fi

ln -sfn "${KEYCLOAK_DIST_DIR}/lib" "${KC_HOME_DIR}/lib"
ln -sfn "${KEYCLOAK_DIST_DIR}/providers" "${KC_HOME_DIR}/providers"
ln -sfn "${KEYCLOAK_DIST_DIR}/themes" "${KC_HOME_DIR}/themes"

exec bash
