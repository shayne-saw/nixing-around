#!/usr/bin/env bash

set -e

REAL_BIN="$(readlink -f "$(command -v neo4j)")"
DIST_DIR="$(dirname "$(dirname "$REAL_BIN")")"

echo -e "🕸️ Creating neo4j home dir and installing base configuration files..."

# Copy default config if missing
if [ ! -d neo4j/conf ]; then
  mkdir -p neo4j
  cp -r "$DIST_DIR/share/neo4j/conf/" neo4j/
  chmod -R u+w neo4j/conf/
  cp neo4j/conf/neo4j.conf neo4j/conf/neo4j.conf.original
fi
