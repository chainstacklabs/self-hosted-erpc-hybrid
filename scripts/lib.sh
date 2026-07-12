#!/usr/bin/env bash
set -euo pipefail

# Load .env if present
if [[ -f "$(dirname "$0")/../.env" ]]; then set -a; . "$(dirname "$0")/../.env"; set +a; fi

# rpc_call <url> <method> <params_json> -> prints raw JSON response
rpc_call() {
  local url="$1" method="$2" params="$3"
  curl -sS --location "$url" \
    --header 'Content-Type: application/json' \
    --data "{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"$method\",\"params\":$params}"
}
