# Agent Feedback

Guidance for AI agents working in this repository. Read before making documentation or content edits.

## Source of Truth

Before writing or editing a doc, read 2-3 *adjacent* docs of the same type and match their voice and structure (not necessarily their literal section names). Verify factual claims against the actual code (`terragrunt.hcl`, `terragrunt.stack.hcl`, workflow files, sibling repos under `../`), not against what an existing doc says, docs drift, code doesn't.

Doc types in this repo, with examples to read before writing one of the same kind:

- **Layer-index** (what a whole directory of things is): `README.md`, `modules/README.md`, `units/README.md`, `stacks/README.md`
- **Unit-group** (what a group of related units does and how they compose): `units/eks/README.md`, `units/eks/addons/argocd/README.md`, `units/tailscale/README.md`, `units/github/README.md`
- **Bootstrap pipeline** (one-time setup, how to deploy it, links out to unit-group docs for detail): `pipelines/bootstrap/tailscale/README.md`, `pipelines/bootstrap/aws_gh_actions_auth/README.md`, `pipelines/bootstrap/setup_dns/README.md`
- **Dev pipeline** (local environment specifics, config file inventory): `pipelines/dev/README.md`, `pipelines/dev/eks/README.md`
- **Operational guide** (procedural, task-oriented): `docs/development.md`, `docs/troubleshoot.md`, `docs/reproducibility.md`

## Style

- Never join list items with slashes (e.g. `dev`/`staging`/`prod` or `aws_eks_cluster`/`aws_eks_cluster_auth`). Use commas and "and" instead (e.g. `dev`, `staging`, and `prod`).
- Never use `;`, `-`, or an em dash (`—`) in the middle of a sentence. Use commas, parentheses, or split into two sentences instead.
- Never join two independent clauses with a comma (comma splice, e.g. "See the issue, there's no fix yet"). Split into two sentences instead.
- Avoid long paragraphs that cram multiple distinct ideas into one block. Break each idea into its own short sentence or paragraph.
- Never number a `###` header or bold lead-in for a sequence of steps (e.g. `### 1. Create a Feature Branch`). Drop the number, order is implied by document flow. A short flat sequence of one-liners can still be a plain numbered markdown list.
