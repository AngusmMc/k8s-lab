
#k3s cluster installation
# cluster info
- kubernetes distro: k3s by Rancher
- version - v1.34.6+

# installation

# control plane
```bash
curl -sfL https://get.k3s.io | sh -
sudo chmod 644 /etc/rancher/k3s/k3s.yaml
```

# worker nodes
```bash
curl -sfL https://get.k3s.io | \
  K3S_URL=https://192.168.50.235:6443 \
  K3S_TOKEN=<token> \
  sh -
```

# verification
```bash
kubectl get nodes
# NAME           STATUS   ROLES           AGE
# k3s-control    Ready    control-plane   4m54s
# k3s-worker-1   Ready    <none>          55s
# k3s-worker-2   Ready    <none>          13s
```
