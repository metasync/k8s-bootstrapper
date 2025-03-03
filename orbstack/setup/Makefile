include Makefile.env
include shared/bootstrap.mk

setup.ingress-nginx:
	@echo "Setting up Ingress Nginx ..." && \
		helm upgrade --install ingress-nginx ingress-nginx \
  		--repo https://kubernetes.github.io/ingress-nginx \
  		--namespace ingress-nginx --create-namespace \
			--kubeconfig ${KUBE_CONFIG} && \
		kubectl wait \
			--namespace ingress-nginx \
			--for=condition=ready pod \
			--selector=app.kubernetes.io/component=controller \
			--timeout=${KUBECTL_WAIT_TIMEOUT} \
			--kubeconfig ${KUBE_CONFIG}

delete.ingress-nginx:
	@kubectl delete namespace ingress-nginx --kubeconfig ${KUBE_CONFIG}


bootstrap.orbstack.cluster: install.helm \
	setup.ingress-nginx \
	install.argocd-cli \
	setup.argocd \
	reset.argocd.password \
	install.argo-cli \
	setup.argo.workflows \
	patch.argo.workflows.authentication \
	setup.argo.events \
	setup.tekton \
	show.post-bootstrap-message

bootstrap.orbstack.cluster.min: install.helm \
	setup.ingress-nginx \
	show.post-bootstrap-message
