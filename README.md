# home-server

## Installation
Install k3s to server
```
export INSTALL_K3S_VERSION="v1.24.10+k3s1"
export K3S_KUBECONFIG_MODE="644"
curl -sfL https://get.k3s.io | sh -s - -server --cluster-init --disable traefik --disable servicelb --write-kubeconfig-mode "0644"
sudo chmod 644 /etc/rancher/k3s/k3s.yaml
sudo cat /var/lib/rancher/k3s/server/node-token
```

Install k3s to agent
```
curl -sfL https://get.k3s.io | K3S_URL=https://1.2.3.4:6334 sh -s - agent --token mypassword
```

Copy k3s.yaml to use kubectl externally
```
sudo cat /etc/rancher/k3s/k3s.yaml
```
Copy to .kube/config on other device and run
```chmod 600 ~/.kube/config```

Install metallb
```
kubectl apply -k metallb
```

Install helm: https://helm.sh/docs/intro/install/

Install longhorn with helm: https://longhorn.io/docs/1.4.0/deploy/install/install-with-helm/
```
helm install longhorn longhorn/longhorn --namespace longhorn-system --create-namespace --version 1.4.0
```

Install argocd
```
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
argocd admin initial-password -n argocd
argocd login <ARGOCD_SERVER_IP>
argocd account update-password
```


