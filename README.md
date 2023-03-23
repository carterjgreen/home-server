# home-server

## Installation
Make firewall rules if on RHEL/derivatives
```
sudo firewall-cmd --permanent --add-port=6443/tcp #apiserver
sudo firewall-cmd --permanent --zone=trusted --add-source=10.42.0.0/16 #pods
sudo firewall-cmd --permanent --zone=trusted --add-source=10.43.0.0/16 #services
sudo firewall-cmd --reload
```
## Install k3s to server
```
export INSTALL_K3S_VERSION="v1.25.7+k3s1" # or don't add this to use stable
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


sudo chmod 644 /etc/rancher/k3s/k3s.yaml
chmod 600 ~/.kube/config
sudo cat /var/lib/rancher/k3s/server/node-token
k config view --raw > ~/.kube/config
```

## Install Cilium
```
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/master/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}

cilium install
cilium status --wait
cilium connectivity test

## Hubble
cilium hubble enable
export HUBBLE_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/hubble/master/stable.txt)
HUBBLE_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then HUBBLE_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/hubble/releases/download/$HUBBLE_VERSION/hubble-linux-${HUBBLE_ARCH}.tar.gz{,.sha256sum}
sha256sum --check hubble-linux-${HUBBLE_ARCH}.tar.gz.sha256sum
sudo tar xzvfC hubble-linux-${HUBBLE_ARCH}.tar.gz /usr/local/bin
rm hubble-linux-${HUBBLE_ARCH}.tar.gz{,.sha256sum}

cilium hubble port-forward&
hubble status

```

## Install k3s to agent
```
export INSTALL_K3S_VERSION="v1.24.10+k3s1"
curl -sfL https://get.k3s.io | K3S_URL=https://1.2.3.4:6443 sh -s - agent --token mypassword
```

Copy k3s.yaml to use kubectl externally
```
sudo cat /etc/rancher/k3s/k3s.yaml
```
Copy to .kube/config on other device and run
```chmod 600 ~/.kube/config```

## Install metallb
```
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.9/config/manifests/metallb-native.yaml
kubectl apply -f metallb/layer2.yaml \
  -f metallb/advertisement.yaml
```

Install helm: https://helm.sh/docs/intro/install/
```
helm repo add traefik https://traefik.github.io/charts
helm repo add longhorn https://charts.longhorn.io
helm repo add jetstack https://charts.jetstack.io
helm repo update
```

## Install longhorn with helm: 
https://longhorn.io/docs/1.4.0/deploy/install/install-with-helm/
```
kubectl apply -f longhorn/longhorn-namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/v1.4.0/deploy/prerequisite/longhorn-iscsi-installation.yaml
kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/v1.4.0/deploy/prerequisite/longhorn-nfs-installation.yaml

kubectl delete -f https://raw.githubusercontent.com/longhorn/longhorn/v1.4.0/deploy/prerequisite/longhorn-iscsi-installation.yaml
kubectl delete -f https://raw.githubusercontent.com/longhorn/longhorn/v1.4.0/deploy/prerequisite/longhorn-nfs-installation.yaml

helm install longhorn longhorn/longhorn --namespace longhorn-system --create-namespace --version 1.4.1 --values=longhorn/longhorn-values.yaml
```

## Install argocd
```
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

kubectl patch svc argocd-server -n argocd -p '{"spec": {"loadBalancerIP": "192.168.1.241"}}'

curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

argocd admin initial-password -n argocd
argocd login 192.168.1.241
argocd account update-password
argocd repo add https://github.com/carterjgreen/home-server.git --username carterjgreen --password <secret>
```

## Install Cert-Manager
```
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager \
     --namespace cert-manager \
     --create-namespace \
     --set installCRDs=true
```

kubectl get namespace "stuck" -o json   | tr -d "\n" | sed "s/\"finalizers\": \[[^]]\+\]/\"finalizers\": []/"   | kubectl replace --raw /api/v1/namespaces/"stuck"/finalize -f -