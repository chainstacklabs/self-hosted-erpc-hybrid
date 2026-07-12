# Self-hosted Ethereum Hoodi node + archive routing to Chainstack Cloud with eRPC

Run a self-hosted Ethereum **Hoodi** testnet full node for the bulk of RPC traffic. Let
[eRPC](https://github.com/erpc/erpc) transparently route archive state, `trace_*`, and `debug_*` to a
Chainstack **Cloud** Hoodi archive node. One endpoint, recent RPC served locally, archive only when
you need it.

> Worked example is on **Hoodi testnet** (cheap to self-host, fits a small box). It's a mechanics
> demo — the identical setup on Ethereum mainnet or Base is where the cost savings land. See the
> tutorial's "Going further" section.

## Prerequisites

- A bare-metal server with [Chainstack Self-Hosted](https://docs.chainstack.com/docs/self-hosted/introduction)
  (partner boxes ship it pre-installed; see the tutorial for the exact Velia config + promo code).
- A [Chainstack](https://console.chainstack.com) account for the Cloud archive node (the free
  Developer plan covers this demo).
- Docker on the server (for eRPC).

## Quickstart

1. Buy a small box and harden it (see [the tutorial](tutorial/self-hosted-eth-hoodi-erpc-cloud.md)).
   Hoodi is light: ~6 vCPU, 32 GB RAM, ~500 GB NVMe is plenty.
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
- `costs.md` — cost breakdown across partners.
