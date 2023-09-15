# K8s-Bootstrapper

## Introduction

K8s-bootstrapper is a tool to automate Kubernetes cluster bootstrapping with default basic components installed and configured. Ater boostrapping, the cluster is ready to use.

K8s-bootstrapper currently support bootstrapping for
  * kind - https://kind.sigs.k8s.io
  * k0s - https://k0sproject.io

We will continue to automate bootstrappping other popular Kubernetes clusters.

The following components are installed by default:

  * Ingress-NGINX controller
    * Nginx as a reverse proxy and load balancer for K8s
    * https://github.com/kubernetes/ingress-nginx
  * Cert-Manager
    * Cloud-native certificate management
    * https://cert-manager.io
  * Argo-CD
    * Declarative, GitOps CD for K8s
    * https://argo-cd.readthedocs.io
  * Tekton
    * Cloud Native CI/CD
    * https://tekton.dev
    * Tekton installs the following: 
      * Pipelines
      * Triggers
      * Dashboard
  * CLIs
    * kubectl - K8s client
    * k0sctl - k0s client
    * kind - kind client
    * argocd - Argo-CD client

## Pre-requisites

### yq

yq is a lightweight and portable command-line YAML, JSON and XML processor. k8s-bootstrapper uses yq to manipulate config in YAML. Please refer to yq on Github for installation instructions:

https://github.com/mikefarah/yq

### Clone this repository

To bootstrap your K8s cluster, you can simply clone this repository and follow the below bootstrapping steps. 

## Bootstrap kind

### Install Docker Desktop / Docker Engine

Since kind is running Kubernetes cluster inside docker container, you need to install Docker Desktop or Docker Engine . Please refer to Docker's official installation guide:

https://docs.docker.com/engine/install/

### Configuration

under `${HOME}/k8s-bootstrapper/kind/setup`, you will be able to find all the configurations needed for bootstrapping kind cluster and related components.

You can review the cluster config file `000_cluster/kind.yaml`. By default, this config will bootstraps 3-node cluster (1 control-plane and 2 workers). You can update nodes to fit your need. Here is a sample config:

```
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: devops
nodes:
  - role: control-plane
    kubeadmConfigPatches:
      - |
        kind: InitConfiguration
        nodeRegistration:
          kubeletExtraArgs:
            node-labels: "ingress-ready=true"
    extraPortMappings:
      - containerPort: 80
        hostPort: 80
        protocol: TCP
      - containerPort: 443
        hostPort: 443
        protocol: TCP
  - role: worker
  - role: worker
```

Please refer to kind official configuration document for more details:

https://kind.sigs.k8s.io/docs/user/configuration/

### Bootstrap

After configuration is updated and reviewed, you are ready to bootstrap your kind cluster:

```
cd ${HOME}/k8s-bootstrapper/kind/setup
make bootstrap.kind.cluster
```

## Bootstrap k0s

### Prepare Kubernete nodes

To setup k0s cluster, you need to prepare your own hosts for cluster nodes. K8s-bootstrapper only setup k0s cluster to the provided hosts.

### Configuration

under `${HOME}/k8s-bootstrapper/k0s/setup`, you will be able to find all the configurations needed for bootstrapping k0s cluster and related components.

You can review the cluster config file:

 `000_cluster/k0s-<cluster name>.yaml`
 
 Default cluster name is "cluster", and thus, its sample config is k0s-**cluster**.yaml. You are highly recommended to rename this with your preferred cluster name.  
 
 By default, this config will bootstraps 3-node cluster (1 controller and 2 workers). You are required to provide IP for each node and user account to bootstrap the cluster node. 
 
 The user account needs to be either root or non-root user with passwordless sudo privilege. Please refer to the following article to setup non-root user with passwordless sudo privilege:

https://timonweb.com/devops/how-to-enable-passwordless-sudo-for-a-specific-user-in-linux/

Here is a sample config:

```
apiVersion: k0sctl.k0sproject.io/v1beta1
kind: Cluster
metadata:
  name: k0s-cluster
spec:
  hosts:
    - ssh:
        address: 10.0.0.1
        user: devops
        port: 22
        keyPath: ~/.ssh/id_rsa
      role: controller
    - ssh:
        address: 10.0.0.2
        user: devops
        port: 22
        keyPath: ~/.ssh/id_rsa
      role: worker
    - ssh:
        address: 10.0.0.3
        user: devops
        port: 22
        keyPath: ~/.ssh/id_rsa
      role: worker
  k0s:
    version: 1.27.5+k0s.0
    dynamicConfig: false
```

### Bootstrap

After configuration is updated and reviewed, you are ready to bootstrap your k0s cluster:

```
cd ${HOME}/k8s-bootstrapper/k0s/setup
make bootstrap.k0s.cluster cluster=<cluster name>
```
