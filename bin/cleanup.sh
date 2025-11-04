#!/usr/bin/env bash

set -e

cd "$(dirname "${BASH_SOURCE[0]}")/.."

rm -rf postgres/
rm -rf keycloak/
rm -rf cassandra/
rm -rf neo4j/
rm -rf opensearch/
