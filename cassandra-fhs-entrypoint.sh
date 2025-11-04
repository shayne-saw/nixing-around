#!/usr/bin/env bash

# Adventure started because I only copied the cassandra.yaml to my local config directory.
# So I was running into issues and in small ways recreating the `cassandra-env.sh` or
# `jvm-server.options` files. Once I figured out I needed to copy the entire conf directory
# everything ran really smoothly.

# The challenge with running Cassandra via nix is that it expects everything to
# be relative to $CASSANDRA_HOME. It expects this of binaries, libs, config,
# data, everything. To get it running smoothly I preferred to leave $CASSANDRA_HOME
# as its default so when it tries to configure paths for libs that works as expected.
# This means you need to configure any directory that Cassandra wants to write to because
# if it tries to write to something relative to $CASSANDRA_HOME it will likely be read-only.
# To do this we need to change the configuration, which is extensive. This entrypoint script
# copies the conf directory for us and patches cassandra.yaml to point to directories
# relative to our project.

set -e

# Ensure yq is available (assumes it's in targetPkgs)
if ! command -v yq >/dev/null; then
  echo "yq is required in targetPkgs for patching cassandra.yaml"
  exit 1
fi

REAL_CASSANDRA_BIN="$(readlink -f "$(command -v cassandra)")"
CASSANDRA_DIST_DIR="$(dirname "$(dirname "$REAL_CASSANDRA_BIN")")"

# Copy default config if missing
if [ ! -d cassandra/conf ]; then
  mkdir -p cassandra
  cp -r "$CASSANDRA_DIST_DIR/conf/" cassandra/
  chmod -R u+w cassandra/conf/
  cp cassandra/conf/cassandra.yaml cassandra/conf/cassandra.yaml.original
fi

# Patch config as needed
yq -y -i '.data_file_directories = ["'"$PWD"'/cassandra/data"]' cassandra/conf/cassandra.yaml
yq -y -i '.commitlog_directory = "'"$PWD"'/cassandra/commitlog"' cassandra/conf/cassandra.yaml
yq -y -i '.saved_caches_directory = "'"$PWD"'/cassandra/caches"' cassandra/conf/cassandra.yaml
yq -y -i '.hints_directory = "'"$PWD"'/cassandra/hints"' cassandra/conf/cassandra.yaml
yq -y -i '.cdc_raw_directory = "'"$PWD"'/cassandra/cdc_raw"' cassandra/conf/cassandra.yaml

# Set up environment variables
export CASSANDRA_CONF="$PWD/cassandra/conf"
export CASSANDRA_LOG_DIR="$PWD/cassandra/logs"

if [ $# -eq 0 ]; then
  exec bash
else
  exec "$@"
fi
