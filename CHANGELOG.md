## [0.1.0] (2023-09-14)

  * First release of k8s-bootstrapper
    * Support bootstrap for:
      * kind
      * k0s
    * Components installed by default:
      * Ingress-NGINX controller
      * Cert-Manager
      * ArgoCD
      * Tekton
        * Pipelines
        * Triggers
        * Dashboard
      * CLIs
        * kubectl
        * k0sctl
        * kind
        * argocd
