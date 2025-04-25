procedure
---

     helm template cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version <VERSION> -f values.yml > cert-manager.yaml 

