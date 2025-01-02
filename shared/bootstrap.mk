install.kubectl:
	@(kubectl version --client 2>&1 |grep -q ${KUBECTL_VERSION} && \
		echo "kubectl ${KUBECTL_VERSION} has been installed.") || \
		(echo "Installing kubectl (${CLI_OS}-${CLI_ARCH}) ..." && \
		mkdir -p ${K8S_BIN} && \
		curl -s -Lo ${K8S_BIN}/kubectl-${CLI_OS}-${CLI_ARCH}-${KUBECTL_VERSION} https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/${CLI_OS}/${CLI_ARCH}/kubectl && \
		chmod +x ${K8S_BIN}/kubectl-${CLI_OS}-${CLI_ARCH}-${KUBECTL_VERSION} && \
		sudo ln -sf ${K8S_BIN}/kubectl-${CLI_OS}-${CLI_ARCH}-${KUBECTL_VERSION} /usr/local/bin/kubectl)


# Cert-Manager bootstrap

setup.cert-manager:
	@echo "Setting up Cert-Manager ..." && \
		kubectl  apply \
			-f https://github.com/cert-manager/cert-manager/releases/download/v${CERT_MANAGER_VERSION}/cert-manager.yaml \
			--validate=false \
			--kubeconfig ${KUBE_CONFIG} && \
		kubectl wait \
			--namespace cert-manager \
			--for=condition=ready pod \
			--selector=app.kubernetes.io/instance=cert-manager \
			--timeout=${KUBECTL_WAIT_TIMEOUT} \
			--kubeconfig ${KUBE_CONFIG} && \
		kubectl apply \
			-f 001_cluster_issuer/cluster-issuer-self-signed.yaml \
			--kubeconfig ${KUBE_CONFIG}

delete.cert-manager:
	@kubectl delete namespace cert-manager --kubeconfig ${KUBE_CONFIG}


# Argo-CD bootstrap

install.argocd-cli:
	@(argocd version --client 2>&1 |grep -q ${ARGOCD_VERSION} && \
		echo "argocd ${ARGOCD_VERSION} has been installed.") || \
		(echo "Installing Argo CD CLI (${CLI_OS}-${CLI_ARCH}) ..." && \
		curl -sSL -o ${K8S_BIN}/argocd-${CLI_OS}-${CLI_ARCH}-${ARGOCD_VERSION} https://github.com/argoproj/argo-cd/releases/download/v${ARGOCD_VERSION}/argocd-${CLI_OS}-${CLI_ARCH} && \
		chmod +x ${K8S_BIN}/argocd-${CLI_OS}-${CLI_ARCH}-${ARGOCD_VERSION} && \
		sudo ln -sf ${K8S_BIN}/argocd-${CLI_OS}-${CLI_ARCH}-${ARGOCD_VERSION} /usr/local/bin/argocd)

setup.argocd:
	@echo "Setting up Argo CD ..." && \
		((kubectl get namespaces --kubeconfig ${KUBE_CONFIG} | grep -q -w argocd && \
		echo "Namespace argocd has been created.") || \
		kubectl create namespace argocd --kubeconfig ${KUBE_CONFIG}) && \
		kubectl apply \
			-n argocd \
			-f https://raw.githubusercontent.com/argoproj/argo-cd/v${ARGOCD_VERSION}/manifests/install.yaml \
			--kubeconfig ${KUBE_CONFIG} && \
		kubectl apply -R -f 002_argocd --kubeconfig ${KUBE_CONFIG}

reset.argocd.password:
	@echo "Admin password of Argo CD is being reset ..." && \
		kubectl patch secret argocd-secret \
			-n argocd \
			-p '{"stringData": { "admin.password": "$(shell argocd account bcrypt --password ${ARGOCD_ADMIN_PASSWORD})", "admin.passwordMtime": "${EXECUTION_DATETIME}" }}' \
			--kubeconfig ${KUBE_CONFIG}

delete.argocd:
	@kubectl delete namespace argocd --kubeconfig ${KUBE_CONFIG}


# Tekton bootstrap

setup.tekton.pipelines:
	@echo "Setting up Tekton Pipelines ..." && \
		kubectl apply \
			-f https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml \
			--kubeconfig ${KUBE_CONFIG} && \
		kubectl wait \
			--namespace tekton-pipelines \
			--for=condition=ready pod \
			--selector=app.kubernetes.io/name=controller \
			--timeout=${KUBECTL_WAIT_TIMEOUT} \
			--kubeconfig ${KUBE_CONFIG} && \
		kubectl wait \
			--namespace tekton-pipelines \
			--for=condition=ready pod \
			--selector=app.kubernetes.io/name=webhook \
			--timeout=${KUBECTL_WAIT_TIMEOUT} \
			--kubeconfig ${KUBE_CONFIG}

setup.tekton.triggers:
	@echo "Setting up Tekton Triggers ..." && \
		kubectl apply \
			-f https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml \
			--kubeconfig ${KUBE_CONFIG} && \
		kubectl apply \
			-f https://storage.googleapis.com/tekton-releases/triggers/latest/interceptors.yaml \
			--kubeconfig ${KUBE_CONFIG} && \
		kubectl wait \
			--namespace tekton-pipelines \
			--for=condition=ready pod \
			--selector=app.kubernetes.io/name=controller \
			--timeout=${KUBECTL_WAIT_TIMEOUT} \
			--kubeconfig ${KUBE_CONFIG} && \
		kubectl wait \
			--namespace tekton-pipelines \
			--for=condition=ready pod \
			--selector=app.kubernetes.io/name=core-interceptors \
			--timeout=${KUBECTL_WAIT_TIMEOUT} \
			--kubeconfig ${KUBE_CONFIG} && \
		kubectl wait \
			--namespace tekton-pipelines \
			--for=condition=ready pod \
			--selector=app.kubernetes.io/name=webhook \
			--timeout=${KUBECTL_WAIT_TIMEOUT} \
			--kubeconfig ${KUBE_CONFIG}

setup.tekton.dashboard:
	@echo "Setting up Tekton Dashboard ..." && \
		kubectl apply \
			-f https://storage.googleapis.com/tekton-releases/dashboard/latest/release.yaml \
			--kubeconfig ${KUBE_CONFIG} && \
		kubectl wait \
			--namespace tekton-pipelines \
			--for=condition=ready pod \
			--selector=app.kubernetes.io/name=dashboard \
			--timeout=${KUBECTL_WAIT_TIMEOUT} \
			--kubeconfig ${KUBE_CONFIG} && \
		kubectl apply \
			-f 003_tekton/tekton-dashboard-ingress.yaml \
			--kubeconfig ${KUBE_CONFIG}

setup.tekton: setup.tekton.pipelines setup.tekton.triggers setup.tekton.dashboard

delete.tekton:
	@kubectl delete namespace tekton-pipelines --kubeconfig ${KUBE_CONFIG} && \
		kubectl delete namespace tekton-pipelines-resolvers --kubeconfig ${KUBE_CONFIG}

install.argo-cli:
	@(argo version 2>&1 |grep -q ${ARGO_WORKFLOWS_VERSION} && \
		echo "argo ${ARGO_WORKFLOWS_VERSION} has been installed.") || \
		(echo "Installing Argo CLI (${CLI_OS}-${CLI_ARCH}) ..." && \
		curl -sSL -o ${K8S_BIN}/argo-${CLI_OS}-${CLI_ARCH}-${ARGO_WORKFLOWS_VERSION}.gz https://github.com/argoproj/argo-workflows/releases/download/v${ARGO_WORKFLOWS_VERSION}/argo-${CLI_OS}-${CLI_ARCH}.gz && \
		gunzip ${K8S_BIN}/argo-${CLI_OS}-${CLI_ARCH}-${ARGO_WORKFLOWS_VERSION}.gz && \
		chmod +x ${K8S_BIN}/argo-${CLI_OS}-${CLI_ARCH}-${ARGO_WORKFLOWS_VERSION} && \
		sudo ln -sf ${K8S_BIN}/argo-${CLI_OS}-${CLI_ARCH}-${ARGO_WORKFLOWS_VERSION} /usr/local/bin/argo)


setup.argo.workflows:
	@echo "Setting up Argo Workflows ..." && \
		((kubectl get namespaces --kubeconfig ${KUBE_CONFIG} | grep -q -w argo && \
		echo "Namespace argo has been created.") || \
		kubectl create namespace argo --kubeconfig ${KUBE_CONFIG}) && \
		kubectl apply \
			-n argo \
			-f https://github.com/argoproj/argo-workflows/releases/download/v${ARGO_WORKFLOWS_VERSION}/install.yaml \
			--kubeconfig ${KUBE_CONFIG} && \
		kubectl apply -R -f 002_argo_workflows --kubeconfig ${KUBE_CONFIG}

patch.argo.workflows.authentication:
	@echo "Authentication mode to Argo Workflows is being switched to 'server' ..." && \
		kubectl patch deployment \
			argo-server \
			--namespace argo \
			--type='json' \
			-p='[{"op": "replace", "path": "/spec/template/spec/containers/0/args", "value": [  \
			"server", \
			"--auth-mode=server" \
			]}]'

delete.argo.workflows:
	@kubectl delete namespace argo --kubeconfig ${KUBE_CONFIG}

setup.argo.events:
	@echo "Setting up Argo Events ..." && \
		((kubectl get namespaces --kubeconfig ${KUBE_CONFIG} | grep -q -w argo-events && \
		echo "Namespace argo-events has been created.") || \
		kubectl create namespace argo-events --kubeconfig ${KUBE_CONFIG}) && \
		kubectl apply \
			-n argo-events \
			-f https://github.com/argoproj/argo-events/releases/download/v${ARGO_EVENTS_VERSION}/install.yaml \
			--kubeconfig ${KUBE_CONFIG} && \
		kubectl apply \
			-n argo-events \
			-f https://github.com/argoproj/argo-events/releases/download/v${ARGO_EVENTS_VERSION}/install-validating-webhook.yaml \
			--kubeconfig ${KUBE_CONFIG}

delete.argo.events:
	@kubectl delete namespace argo-events --kubeconfig ${KUBE_CONFIG}

install.helm:
	@(helm version 2>&1 |grep -q ${HELM_VERSION} && \
		echo "helm ${HELM_VERSION} has been installed.") || \
		(echo "Installing helm (${CLI_OS}-${CLI_ARCH}) ..." && \
		mkdir -p ${HELM_TMP} && \
		curl -sSL -o ${HELM_TMP}/helm-${CLI_OS}-${CLI_ARCH}-${HELM_VERSION}.tar.gz https://get.helm.sh/helm-v${HELM_VERSION}-${CLI_OS}-${CLI_ARCH}.tar.gz && \
		tar -zxf ${HELM_TMP}/helm-${CLI_OS}-${CLI_ARCH}-${HELM_VERSION}.tar.gz -C ${HELM_TMP} && \
		mv ${HELM_TMP}/${CLI_OS}-${CLI_ARCH}/helm ${K8S_BIN}/helm-${CLI_OS}-${CLI_ARCH}-${HELM_VERSION} && \
		rm -fr ${HELM_TMP} && \
		sudo ln -sf ${K8S_BIN}/helm-${CLI_OS}-${CLI_ARCH}-${HELM_VERSION} /usr/local/bin/helm) 

show.post-bootstrap-message:
	@echo && \
		echo "Congratulation! Your kubernetes cluster has been bootstrapped successfully." && \
		echo
