#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
[[ -f .env ]] && { set -a; . .env; set +a; }
ERPC="${ERPC_BASE:-http://localhost:4000/main/evm/560048}"

post() {
  curl -sS --location "$ERPC" --header 'Content-Type: application/json' \
    --data "{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"$1\",\"params\":$2}"
}

echo "== recent (expect served by self-hosted) =="
post "eth_blockNumber" '[]' | jq .

echo "== archive method (expect served by Cloud) =="
post "trace_block" '["0x1"]' | jq '.result | length'

echo "== old-state read (expect failover to Cloud on pruned state) =="
post "eth_getBalance" '["0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045","0x1"]' | jq .
