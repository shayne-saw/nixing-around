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
  cp keycloak/conf/keycloak.conf keycloak/conf/keycloak.conf.original
fi

# TODO: Unsure if this is actually needed.
# Was having trouble getting this to run because keycloak (quarkus) is trying
# to build binaries and store them in the /nix/store. Went to see how the
# nixos service was working and saw this:
# https://github.com/NixOS/nixpkgs/blob/nixos-25.05/nixos/modules/services/web-apps/keycloak.nix#L745
ln -sfn "${KEYCLOAK_DIST_DIR}/lib" "${KC_HOME_DIR}/lib"
ln -sfn "${KEYCLOAK_DIST_DIR}/providers" "${KC_HOME_DIR}/providers"
ln -sfn "${KEYCLOAK_DIST_DIR}/themes" "${KC_HOME_DIR}/themes"

if [ $# -eq 0 ]; then
  exec bash
else
  exec "$@"
fi
