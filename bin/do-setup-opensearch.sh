#!/usr/bin/env bash

set -e

REAL_BIN="$(readlink -f "$(command -v opensearch)")"
DIST_DIR="$(dirname "$(dirname "$REAL_BIN")")"

echo -e "🔍 Creating opensearch home dir and installing base configuration files..."

# Copy default config if missing
if [ ! -d opensearch ]; then
  mkdir -p opensearch
  cp -r "$DIST_DIR/config/" opensearch/
  chmod -R u+w opensearch/config/
  mv opensearch/config/opensearch.yml opensearch/config/opensearch.yml.original
  cp opensearch/config/jvm.options opensearch/config/jvm.options.original
fi

mkdir -p opensearch/{logs,data}

# Without changing this configuration, OpenSearch will try to write data and logs
# to a subdirectory of the installation directory, which doesn't work with nix.
#
# NOTE: Start with an empty mapping otherwise yq doesn't write anything.
echo "{}" >opensearch/config/opensearch.yml
yq -yi '.path.data = "'"$PWD"'/opensearch/data"' opensearch/config/opensearch.yml
yq -yi '.path.logs = "'"$PWD"'/opensearch/logs"' opensearch/config/opensearch.yml
yq -yi '.plugins.security.ssl.http.enabled = false' opensearch/config/opensearch.yml
yq -yi '.plugins.security.ssl.transport.enabled = false' opensearch/config/opensearch.yml
yq -yi '.plugins.security.disabled = true' opensearch/config/opensearch.yml

# Default configuration writes GC logs to logs/gc.log, which is relative to the installation
# so we substitute an absolute path here that writes to our project directory.
sed -i 's|logs/gc\.log|'"$PWD"'/opensearch/logs/gc.log|g' opensearch/config/jvm.options
