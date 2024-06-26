include Makefile.env
include shared/bootstrap.mk

install.kind-cli:
	@(kind version 2>&1 |grep -q ${KIND_VERSION} && \
		echo "kind ${KIND_VERSION} has been installed.") || \
		(echo "Installing Kind CLI (${CLI_OS}-${CLI_ARCH}) ..." && \
	 	mkdir -p ${KIND_BIN} && \
		curl -s -Lo ${KIND_BIN}/kind-${CLI_OS}-${CLI_ARCH}-${KIND_VERSION} https://kind.sigs.k8s.io/dl/v${KIND_VERSION}/kind-${CLI_OS}-${CLI_ARCH} && \
		chmod +x ${KIND_BIN}/kind-${CLI_OS}-${CLI_ARCH}-${KIND_VERSION} && \
		sudo ln -sf ${KIND_BIN}/kind-${CLI_OS}-${CLI_ARCH}-${KIND_VERSION} /usr/local/bin/kind)

create.kind.cluster:
	@kind create cluster --config=000_cluster/kind.yaml

delete.kind.cluster:
	@kind delete cluster --name ${KIND_CLUSTER_NAME}

info.kind.cluster:
	@kubectl cluster-info --context kind-${KIND_CLUSTER_NAME} --kubeconfig ${KUBE_CONFIG}


setup.ingress-nginx:
	@echo "Setting up Ingress Nginx ..." && \
		kubectl apply \
			-f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml \
			--kubeconfig ${KUBE_CONFIG} && \
		kubectl wait \
			--namespace ingress-nginx \
			--for=condition=ready pod \
			--selector=app.kubernetes.io/component=controller \
			--timeout=${KUBECTL_WAIT_TIMEOUT} \
			--kubeconfig ${KUBE_CONFIG}

delete.ingress-nginx:
	@kubectl delete namespace ingress-nginx --kubeconfig ${KUBE_CONFIG}


bootstrap.kind.cluster: install.kubectl install.kind-cli \
  create.kind.cluster \
	setup.ingress-nginx \
	setup.cert-manager \
	install.argocd-cli \
	setup.argocd \
	reset.argocd.password \
	install.argo-cli \
	setup.argo.workflows \
	patch.argo.workflows.authentication \
	setup.argo.events \
	setup.tekton \
	show.post-bootstrap-message

