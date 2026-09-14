procedure
---

    helm template rancher rancher-stable/rancher --namespace cattle-system -f values.yaml --no-hooks --version 2.14.5 --kube-version <KUBE_VERSION> > rancher.yml
    kubectl apply -n cattle-system -f rancher.yml 
