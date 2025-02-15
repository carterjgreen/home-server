[group('install-tools')]
install-apt:
    sudo apt install yamllint jq

[group('install-tools')]
install-helm:
    curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
    sudo apt-get install apt-transport-https --yes
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
    sudo apt-get update
    sudo apt-get install helm

[group('install-tools')]
install-argo-cli:
    curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
    sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
    rm argocd-linux-amd64

# install some repo necessary tools
[group('install-tools')]
install-tools: install-helm install-apt

[group('bootstrap')]
install-cilium:
    CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
    CLI_ARCH=amd64
    if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
    curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
    sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
    sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
    rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}

    cilium install --version 1.16.2

[group('bootstrap')]
install-argocd: 
    kubectl create ns argocd
    kubectl apply -f secrets
    helm install argocd argo/argo-cd \
    --namespace=argocd \
    --values=bootstrap/argocd/values.yaml 

    helm install argocd-apps argo/argocd-apps \
    --namespace=argocd \
    --values=bootstrap/argocd-apps/values.yaml 

[group('ci')]
lint:
    yamllint . --no-warnings

[group('ci')]
renovate:
    npx --yes --package renovate -- renovate-config-validator