# home-server

## Installation

Make firewall rules if on RHEL/derivatives

```bash
sudo firewall-cmd --permanent --add-port=6443/tcp #apiserver
sudo firewall-cmd --permanent --zone=trusted --add-source=10.42.0.0/16 #pods
sudo firewall-cmd --permanent --zone=trusted --add-source=10.43.0.0/16 #services
sudo firewall-cmd --reload
```

## Install k3s to server

```bash
export INSTALL_K3S_VERSION="v1.27.3+k3s1" # or don't add this to use stable
export K3S_KUBECONFIG_MODE="644"
export K3S_DATASTORE_ENDPOINT='postgres://username:password@192.168.1.99:5432/k3s?sslmode=disable'
export K3S_RESOLV_CONF=/etc/resolv.conf
curl -sfL https://get.k3s.io | sh -s - -server \
  --cluster-init \
  --disable traefik \
  --disable servicelb \
  --prefer-bundled-bin \
  --write-kubeconfig-mode "0644" \
  --flannel-backend=none \
  --disable-network-policy \
  --tls-san 192.168.1.99

  --token <token>

alias k=kubectl
sudo chmod 644 /etc/rancher/k3s/k3s.yaml
sudo cat /var/lib/rancher/k3s/server/node-token
k config view --raw > ~/.kube/config
chmod 600 ~/.kube/config
```

## Install k3s to agent

```bash
export INSTALL_K3S_VERSION="v1.27.3+k3s1"
curl -sfL https://get.k3s.io | K3S_URL=https://1.2.3.4:6443 sh -s - agent --token mypassword
```

## Install helm: <https://helm.sh/docs/intro/install/>

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo add crowdsec https://crowdsecurity.github.io/helm-charts
helm repo update
```

## Install cilium

```bash
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}

cilium install --version 1.14.0
```

## Install argocd

```bash
kubectl create ns argocd
kubectl apply -f secrets
helm install argocd argo/argo-cd \
  --namespace=argocd \
  --values=bootstrap/argocd/values.yaml 

helm install argocd-apps argo/argocd-apps \
  --namespace=argocd \
  --values=bootstrap/argocd-apps/values.yaml 
kubectl apply -f secrets

curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

argocd admin initial-password -n argocd

kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
kubectl patch svc argocd-server -n argocd -p '{"spec": {"loadBalancerIP": "192.168.1.241"}}'
argocd login 192.168.1.241
argocd account update-password
```
