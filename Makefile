.PHONY: validate schema rbac test lint

validate: schema rbac test lint ## Run every local check

schema:
	kubeconform -strict -summary manifests/*.yaml

rbac:
	scripts/check-rbac.sh

test:
	scripts/test-check-rbac.sh

lint:
	shellcheck scripts/*.sh
