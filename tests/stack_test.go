package tests

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terragrunt"
)

func TestLocalStack(t *testing.T) {
	t.Parallel()

	ctx := t.Context()

	// Edit this variable to point to your stack
	// Path is relative to the `tests/` directory.
	// TODO: switch back to the full EKS stack once ArgoCD login test is validated
	// stackDir := "../pipelines/examples/stacks/eks"
	stackDir := "../pipelines/examples/stacks/vpc_only"

	options := &terragrunt.Options{
		// Run from the examples subfolder where the terragrunt configs are
		TerragruntDir: stackDir,
		// Optional: Set log level for cleaner output
		TerragruntArgs: []string{"--log-level", "error"},
	}

	// Clean up all modules with "terragrunt destroy --all" at the end of the test.
	// DestroyAll respects the reverse dependency order.
	defer terragrunt.DestroyAllContext(t, ctx, options)

	// Run "terragrunt apply --all". This applies all modules in dependency order.
	terragrunt.ApplyAllContext(t, ctx, options)

	allOutputs := terragrunt.StackOutputAllContext(t, ctx, options)
	host := allOutputs["route53_hosted_zone_private"].(map[string]any)["domain_name"].(string)
	t.Logf("ArgoCD host: %s", host)
}