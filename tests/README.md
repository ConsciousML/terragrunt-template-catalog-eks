# Test Terragrunt Stacks With Terratest

## Installation
Follow the [installation instructions](../README.md#installation):

## Write a Test
Copy `tests/stack_test.go` in the `test` directory. Use the suffix `*_test.go`.

Next, change the stack directory to the path of the stack you want to test:
```go
stackDir := "../pipelines/examples/stacks/eks"
```

Finally, write additional tests steps. For example, you can perform health checks or make a request to an API to ensure your infrastructure was deployed properly.

## Why Creating an External Test Example?
Creating an `examples` folder is a best practice to provide complete Terraform configurations that call the module and supply any required dependencies.

This makes testing easier and helps others understand how to use the module.

In our case, the `pipelines/examples/stacks/eks` configuration calls the units in the `units/` directory.

This has the benefit to use environment variables specific to an `example` environment (i.e all `region.hcl`, `environment.hcl` in `pipelines/`).

## Run Terratest
Setup the go module, replacing `<your_github_username>` and `<your_forked_repo_name>` if you forked the repository:
```bash
go mod init github.com/<your_github_username>/<your_forked_repo_name>
go get github.com/gruntwork-io/terratest@v1.0.0
go get github.com/aws/aws-sdk-go-v2/aws
go get github.com/aws/aws-sdk-go-v2/config
go get github.com/aws/aws-sdk-go-v2/service/secretsmanager
go mod tidy
```

Set required environment variables before running:
```bash
export AWS_REGION=<your-aws-region>   # e.g. us-east-1 — required, tests fail immediately if unset
```

Run the test:
```bash
go test -v ./tests/... -timeout 60m
```