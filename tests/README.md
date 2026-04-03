# Test Terragrunt Stacks With Terratest

## Installation
Follow the [installation instructions](../README.md#installation):

## Write a test
Copy `tests/stack_test.go` in the `test` directory. Use the suffix `*_test.go`.

Next, change the stack directory to the path of the stack you want to test:
```go
stackDir := "../examples/stacks/eks"
```

Finally, write additional tests steps. For example, you can perform health checks or make a request to an API to ensure your infrastructure was deployed properly.

## Why creating an external test example?
Creating an `examples` folder is a best practice to provide complete Terraform configurations that call the module and supply any required dependencies.

This makes testing easier and helps others understand how to use the module.

In our case, the `examples/stacks/eks` configuration calls the units in the `units/` directory.

This has the benefit to use environment variables specific to an `example` environment (i.e all `region.hcl`, `environment.hcl` in `examples/`).

## Run Terratest
Setup the go module:
```bash
go mod init github.com/ConsciousML/terragrunt-template-stack-eks
go get github.com/gruntwork-io/terratest@v0.56.0
go mod tidy
```

Run the test:
```bash
go test -v ./tests/... -timeout 30m
```