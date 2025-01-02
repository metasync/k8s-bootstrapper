## [0.2.0] (2025-01-02)

  * k0s
    * Added helm installation
    * Added minimum bootstrap for k0s cluster
  * kind
    * Upgraded Kind to 0.26.0 from 0.24.0
    * Added minimum bootstrap for Kind cluster
  * Added support for Orbstack
  * Updated the following software versions:
    * cert manager - 1.16.2
    * argocd - 2.13.2
    * argo workflows - 3.6.2
    * argo events - 1.9.3
    * helm - 3.16.4
  * Added helm cli installation

## [0.1.1] (2024-05-24)

  * Added default components installed:
    * Argo Workflows & Argo CLI
    * Argo Event
  * Updated versions for default components:
    * Cert Manager to 1.14.5
    * ArgoCD to 2.8.3
  * Updated Kind version to 0.23.0
  * Updated K9s version to 1.29.2+k0s.0

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
