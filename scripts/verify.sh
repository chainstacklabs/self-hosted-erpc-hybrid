#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
[[ -f .env ]] && { set -a; . .env; set +a; }
ERPC="${ERPC_BASE:-http://localhost:4000/main/evm/560048}"
METRICS="${METRICS_BASE:-http://localhost:4001/metrics}"

# count(upstream, method) = requests served by an upstream for one specific method.
# Filtering by category keeps eRPC's own background pollers (which also hit the
# upstreams and bump erpc_upstream_request_total) from skewing the before/after delta.
count() {
  curl -sS "$METRICS" \
    | grep 'erpc_upstream_request_total' \
    | grep "upstream=\"$1\"" \
    | grep "category=\"$2\"" \
    | awk '{s+=$NF} END{print s+0}'
}

post() { curl -sS --location "$ERPC" --header 'Content-Type: application/json' --data "$1" >/dev/null; }

before_local=$(count "self-hosted-eth" "eth_blockNumber")
post '{"jsonrpc":"2.0","id":1,"method":"eth_blockNumber","params":[]}'
after_local=$(count "self-hosted-eth" "eth_blockNumber")
if (( after_local == before_local )); then
  # the result may have come from eRPC's 5s unfinalized cache — wait it out, retry once
  sleep 6
  post '{"jsonrpc":"2.0","id":1,"method":"eth_blockNumber","params":[]}'
  after_local=$(count "self-hosted-eth" "eth_blockNumber")
fi

# random old block busts the permanent finalized-result cache, so the trace call
# must reach an upstream instead of being answered from eRPC's memory
BLOCK=$(printf '0x%x' $((4096 + RANDOM)))
before_cloud=$(count "chainstack-cloud-eth" "trace_block")
post "{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"trace_block\",\"params\":[\"$BLOCK\"]}"
after_cloud=$(count "chainstack-cloud-eth" "trace_block")

fail=0
if (( after_local > before_local )); then echo "PASS: recent call served by self-hosted"; else echo "FAIL: recent call did not hit self-hosted"; fail=1; fi
if (( after_cloud > before_cloud )); then echo "PASS: archive call served by Cloud"; else echo "FAIL: archive call did not hit Cloud"; fail=1; fi
exit $fail
