procedure
---

    helm template rancher rancher-stable/rancher --namespace cattle-system -f values.yaml --version <VERSION> > rancher.yml

