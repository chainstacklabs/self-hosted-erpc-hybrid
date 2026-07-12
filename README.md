<img width="1200" alt="Labs" src="https://user-images.githubusercontent.com/99700157/213291931-5a822628-5b8a-4768-980d-65f324985d32.png">

<p>
 <h3 align="center">Chainstack is the leading suite of services connecting developers with Web3 infrastructure</h3>
</p>

<p align="center">
  • <a target="_blank" href="https://chainstack.com/">Homepage</a> •
  <a target="_blank" href="https://chainstack.com/protocols/">Supported protocols</a> •
  <a target="_blank" href="https://chainstack.com/blog/">Chainstack blog</a> •
  <a target="_blank" href="https://docs.chainstack.com/quickstart/">Blockchain API reference</a> • <br> 
  • <a target="_blank" href="https://console.chainstack.com/user/account/create">Start for free</a> •
</p>

# Hybrid RPC: self-hosted node + Chainstack Cloud archive behind one eRPC endpoint

This tutorial shows a **hybrid RPC setup**: run your own full node for the bulk of your RPC traffic,
and let [eRPC](https://github.com/erpc/erpc) transparently route what your node can't serve — archive
state, `trace_*`, and `debug_*` — to a Chainstack Cloud archive node. Your apps see one endpoint;
recent calls are served locally at flat hardware cost, and you pay for archive only when you actually
need it.

The worked example runs on **Ethereum Hoodi** — a testnet that's cheap to self-host and fits a small
box — but the pattern is chain-agnostic. The same eRPC config with a different `chainId` works on any
EVM network from the [protocols supported by Chainstack Self-Hosted](https://docs.chainstack.com/docs/self-hosted/supported-clients-and-protocols),
and mainnets like Ethereum or Base are where the cost savings land.

## New to this? Start here

The three moving parts:

- **Full node** — keeps recent chain state. Cheap to run, and covers ~95% of typical app traffic:
  balances, transactions, logs, contract calls at recent blocks.
- **Archive node** — keeps *all* historical state. Expensive to self-host (multi-TB disk, long sync),
  but required for `trace_*`, `debug_*`, and state reads at old blocks.
- **eRPC** — an open-source RPC proxy that sits in front of both. It routes each request by method,
  fails over when the full node errors (for example, on pruned state), and caches finalized results
  so repeat archive hits cost nothing.

The hybrid idea: self-host the cheap full node, rent the expensive archive as a managed
[Chainstack](https://chainstack.com) node, and let eRPC decide per request. You get one endpoint
and the cheapest viable path for every call.

Suggested path through this repo:

1. Read [the tutorial](tutorial/self-hosted-eth-hoodi-erpc-cloud.md) — the full walkthrough, built
   and verified on a real server, including the gotchas we hit.
2. Skim [`erpc/erpc.yaml`](erpc/erpc.yaml) — the entire routing logic is ~60 commented lines.

## Prerequisites

- A bare-metal server with [Chainstack Self-Hosted](https://docs.chainstack.com/docs/self-hosted/introduction).
  Any provider works; the [partner providers](https://chainstack.com/self-hosted/) offer discounts and
  ship the Control Panel pre-installed. The worked example uses a Velia box — see the tutorial for the
  exact config and promo code.
- A [Chainstack account](https://console.chainstack.com) for the Cloud archive node.
- Docker on the server, for eRPC.

## Quickstart

1. Buy a small box and harden it (see [the tutorial](tutorial/self-hosted-eth-hoodi-erpc-cloud.md)).
   Hoodi is light: ~6 vCPU, 32 GB RAM, and ~500 GB NVMe is plenty.
2. Deploy the Hoodi full node (Chainstack Self-Hosted) and a Chainstack Cloud Hoodi **archive** node.
3. On the box, copy `.env.example` to `.env` and fill in your endpoints. `SELF_HOSTED_RPC_URL` is the
   node's `reth-rpc` ClusterIP (routable from the k3s host):
   ```bash
   kubectl -n control-panel-deployments get svc | grep reth-rpc
   ```
4. Run eRPC on the box with host networking, so it reaches the node over the cluster network while
   its ports 4000/4001 stay firewalled from the internet:
   ```bash
   docker run -d --name erpc --restart unless-stopped --network host \
     -v $(pwd)/erpc/erpc.yaml:/erpc.yaml --env-file .env ghcr.io/erpc/erpc:main
   ```
5. Prove the routing split (on the box): `./scripts/test-routing.sh && ./scripts/verify.sh`

## What's here

- `tutorial/` — the full walkthrough (canonical source for all derived content).
- `erpc/erpc.yaml` — the working eRPC config.
- `scripts/` — verification that recent calls stay local and archive calls hit Cloud.

## Running this on another chain

Swap the `chainId` in `erpc/erpc.yaml` and `.env`, deploy the matching self-hosted node and Cloud
archive node, and the routing works unchanged. See the
[supported clients and protocols](https://docs.chainstack.com/docs/self-hosted/supported-clients-and-protocols)
for what Chainstack Self-Hosted can run, and the
[networks list](https://docs.chainstack.com/docs/protocols-networks) for what's available on
Chainstack Cloud. Note that eRPC routes EVM chains only.
