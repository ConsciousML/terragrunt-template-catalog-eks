.PHONY: clean sync-lock-files trivy

clean:
	terragrunt stack clean
	find . -type d -name ".terraform*" -exec rm -rf {} +
	find . -type f -name ".terraform*" ! -name ".terraform-docs.yml" -exec rm -f {} +

sync-lock-files:
	./scripts/sync-lock-files.sh

trivy:
	cd pipelines && terragrunt stack run init
	./scripts/trivy-scan-stack.sh
