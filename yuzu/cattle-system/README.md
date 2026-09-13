procedure
---

    helm template rancher rancher-stable/rancher --namespace cattle-system -f values.yaml --no-hooks --version <VERSION> --kube-version <KUBE_VERSION> > rancher.yml
    kubectl apply -n cattle-system -f rancher.yml 
