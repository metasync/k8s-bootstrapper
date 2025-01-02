include Makefile.env
include shared/bootstrap.mk

ifeq (${CLI_ARCH},amd64)
    K0SCTL_ARCH := x64
else
    K0SCTL_ARCH := ${CLI_ARCH}
endif

install.k0sctl:
	@(k0sctl version 2>&1 |grep -q ${K0SCTL_VERSION} && \
		echo "k0sctl ${K0SCTL_VERSION} has been installed.") || \
		(echo "Installing k0sctl ..." && \
		mkdir -p ${K0S_BIN} && \
		curl -s -Lo ${K0S_BIN}/k0sctl-${CLI_OS}-${K0SCTL_ARCH}-${K0SCTL_VERSION} https://github.com/k0sproject/k0sctl/releases/download/v${K0SCTL_VERSION}/k0sctl-${CLI_OS}-${K0SCTL_ARCH} && \
		chmod +x ${K0S_BIN}/k0sctl-${CLI_OS}-${K0SCTL_ARCH}-${K0SCTL_VERSION} && \
		sudo ln -sf ${K0S_BIN}/k0sctl-${CLI_OS}-${K0SCTL_ARCH}-${K0SCTL_VERSION} /usr/local/bin/k0sctl)

create.k0s.cluster:
	@yq e -i '.metadata.name = ${K0S_CLUSTER_NAME}' 000_cluster/$(K0SCTL_CONFIG_FILE) && \
		yq e -i '.spec.k0s.version = ${K0S_VERSION}' 000_cluster/$(K0SCTL_CONFIG_FILE) && \
		k0sctl apply --config 000_cluster/$(K0SCTL_CONFIG_FILE) && \
		mkdir -p ${K0S_CONFIG_PATH} && \
		k0sctl kubeconfig --config 000_cluster/$(K0SCTL_CONFIG_FILE) > ${K0S_CONFIG} && \
		ln -s ${K0S_CONFIG} ${KUBE_CONFIG}

delete.k0s.cluster:
	@k0sctl reset --config 000_cluster/$(K0SCTL_CONFIG_FILE)


setup.ingress-nginx:
	@echo "Setting up Ingress Nginx ..." && \
		kubectl apply \
			-f 001_ingress_nginx/deploy-${INGRESS_NGINX_VERSION}.yaml \
			--kubeconfig ${KUBE_CONFIG} && \
		kubectl wait \
			--namespace ingress-nginx \
			--kubeconfig ${KUBE_CONFIG} \
			--for=condition=ready pod \
			--selector=app.kubernetes.io/component=controller \
			--timeout=${KUBECTL_WAIT_TIMEOUT}

delete.ingress-nginx:
	@kubectl delete namespace ingress-nginx --kubeconfig ${KUBE_CONFIG}

bootstrap.k0s.cluster: install.kubectl install.k0sctl install.helm \
	create.k0s.cluster \
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

bootstrap.k0s.cluster.min: install.kubectl install.k0sctl install.helm \
	create.k0s.cluster \
	setup.ingress-nginx \
	setup.cert-manager \
	show.post-bootstrap-message
