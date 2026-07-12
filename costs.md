# Cost breakdown

Worked example: **Ethereum Hoodi testnet**, self-hosted full node + Chainstack Cloud archive via eRPC.
All self-hosted components on one Velia promo box; Cloud serves only archive/failover.

## Ongoing monthly

| Item | What | Monthly |
|---|---|---|
| Velia server (promo box) | E-2286G, 32 GB, 1×960 GB SSD + 2×960 GB NVMe, Chainstack Self-Hosted | **€109** |
| Chainstack Cloud (Hoodi archive) | Free **Developer** plan — 3M RU/mo included, 25 RPS | **$0** |
| eRPC | Open-source, self-run | **$0** |
| **Ongoing total** | | **≈ €109/mo** |

## First month (with promo)

| Item | Monthly | First month |
|---|---|---|
| Velia box, promo `ChainstackSH80` (80% off first month) | €109 | **≈ €21.80** |
| Cloud + eRPC | $0 | $0 |
| **First-month total** | | **≈ €22** |

## Why the Cloud side is $0 here

Chainstack bills by request units (RU): **1 RU per request on a full node, 2 RU on an archive node**
(no per-method multipliers). The free **Developer** plan includes **3,000,000 RU/mo** — i.e. ~1.5M
archive requests. A testnet demo's archive/`trace_`/`debug_` traffic is far below that, so the Cloud
upstream costs nothing. eRPC's finalized-data cache keeps it even lower.

## Partner first-month discounts (for reference)

| Partner | Promo | Discount | Applies to |
|---|---|---|---|
| Velia | `ChainstackSH80` | 80% off first month | this box |
| BreezeHost | `CHAINSTACK50` | 50% off first month | their Chainstack plans |
| Serverside | (auto via link) | 10% **ongoing** | their boxes |
| Vultr / Hostkey | — | — | — |

## Mainnet note

This is a **testnet mechanics demo**, so the Cloud side is free and there's no real "archive is
expensive" pressure. On **mainnet** (Ethereum or Base), you'd:
- run a bigger self-hosted box (mainnet full node: ~2–3.5 TB NVMe, more RAM/CPU), and
- size a paid Cloud plan (e.g. **Growth $49/mo**, 20M RU) for the archive/failover volume.

That's where the model pays off: the self-hosted full node absorbs unlimited cheap recent traffic at
flat hardware cost, and you pay Cloud only for the archive slice you can't feasibly self-host —
instead of paying for full archive access on everything.
