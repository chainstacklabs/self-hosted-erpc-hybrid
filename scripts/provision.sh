#!/usr/bin/env bash
# provision.sh — base tooling for a Chainstack Self-Hosted box (run as root on the SERVER).
#
# Only needed if your box did NOT ship with the Control Panel pre-installed
# (partner boxes ordered with the "Chainstack Self-Hosted" management option have it).
#
# SAFE + NON-DESTRUCTIVE: installs k3s, helm, yq and verifies the cluster.
# It deliberately STOPS before touching disks (LVM/TopoLVM) and before the
# interactive `cpctl install`, because those depend on the box's actual device
# layout (see `lsblk`) and prompt for input. Follow the tutorial for those.
#
# Source: docs.chainstack.com/docs/self-hosted/{environment-setup,quick-start,download-installer}
set -euo pipefail

echo "== 1/5 apt prerequisites =="
apt update
apt install -y curl gpg wget apt-transport-https openssl lvm2

echo "== 2/5 Helm =="
if ! command -v helm >/dev/null; then
  curl -fsSL https://packages.buildkite.com/helm-linux/helm-debian/gpgkey | gpg --dearmor | tee /usr/share/keyrings/helm.gpg > /dev/null
  echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://packages.buildkite.com/helm-linux/helm-debian/any/ any main" | tee /etc/apt/sources.list.d/helm-stable-debian.list
  apt update
  apt install -y helm
fi
helm version

echo "== 3/5 yq (mikefarah) =="
if ! command -v yq >/dev/null; then
  wget -q https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/local/bin/yq
  chmod +x /usr/local/bin/yq
fi
yq --version

echo "== 4/5 k3s (lightweight Kubernetes) =="
if ! command -v kubectl >/dev/null; then
  curl -sfL https://get.k3s.io | sh -
fi
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
grep -q 'KUBECONFIG=/etc/rancher/k3s/k3s.yaml' /etc/environment || echo 'KUBECONFIG=/etc/rancher/k3s/k3s.yaml' >> /etc/environment
kubectl cluster-info
kubectl get nodes

echo "== 5/5 cpctl (Chainstack Self-Hosted CLI) =="
if ! command -v cpctl >/dev/null; then
  curl -sSL https://install.chainstack.com/cpctl.sh | sh
fi
cpctl version

echo
echo "== base tooling done. STOP HERE. =="
echo "Next (see the tutorial, needs judgement / is interactive):"
echo "  - Inspect disks:            lsblk"
echo "  - Put chain data on NVMe    (repoint k3s local-path, or LVM + TopoLVM) — device paths vary, do NOT guess"
echo "  - Install Control Panel:    cpctl install -s <storage-class> --backend-url http://<SERVER-IP>:8081"
echo "  - Deploy an Ethereum Hoodi node via the Control Panel UI (RPC stays internal: ClusterIP only)"
