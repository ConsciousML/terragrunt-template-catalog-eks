.PHONY: clean sync-lock-files

clean:
	terragrunt stack clean
	find . -type d -name ".terraform*" -exec rm -rf {} +
	find . -type f -name ".terraform*" ! -name ".terraform-docs.yml" -exec rm -f {} +

sync-lock-files:
	./scripts/sync-lock-files.sh
