---
name: how-to-write-docs
description: Rules for writing or editing Markdown docs or inline code comments in this repo (README.md, docs/, unit/module docs, comments). Use before writing or editing any doc or comment.
---

If documenting `argocd-app-of-apps-template`, also read its
[`how-to-write-docs` skill](https://github.com/ConsciousML/argocd-app-of-apps-template/blob/main/.claude/skills/how-to-write-docs/SKILL.md)
for rules specific to that repo.

## Source of Truth

Before writing or editing a doc, read 2-3 *adjacent* docs of the same type and match their voice
and structure, not necessarily their literal section names. Verify factual claims against the
actual code (`terragrunt.hcl`, `terragrunt.stack.hcl`, workflow files, sibling repos under `../`),
not against what an existing doc says, docs drift, code doesn't.

Doc types in this repo, with examples to read before writing one of the same kind:

- **Layer-index** (what a whole directory of things is): `README.md`, `modules/README.md`,
  `units/README.md`, `stacks/README.md`
- **Unit-group** (what a group of related units does and how they compose):
  `units/eks/README.md`, `units/eks/addons/argocd/README.md`, `units/tailscale/README.md`,
  `units/github/README.md`
- **Bootstrap pipeline** (one-time setup, how to deploy it, links out to unit-group docs for
  detail): `pipelines/bootstrap/tailscale/README.md`, `pipelines/bootstrap/aws_gh_actions_auth/README.md`,
  `pipelines/bootstrap/setup_dns/README.md`
- **Dev pipeline** (local environment specifics, config file inventory): `pipelines/dev/README.md`,
  `pipelines/dev/eks/README.md`
- **Operational guide** (procedural, task-oriented): `docs/development.md`, `docs/troubleshoot.md`,
  `docs/reproducibility.md`

## Content

- Only document facts that aren't obvious from the code.
- Don't restate a value that can drift out of sync with the code (a pinned version, a count, an
  exclusivity claim like "the only" or "single"). Point at the file that holds the value instead.

## Dependencies

- List what a component depends on under `## Upstream Dependencies`. Don't also list who depends
  on it, that's the same fact stated twice.
- Keep a downstream mention only if it warns of a real gotcha (a name that must match, a required
  order, a silent failure). Otherwise cut it.
- Before cutting one, check it isn't the only record of that dependency (compare against the
  `dependency` blocks in `terragrunt.hcl`). If it is, move it to the consumer's own doc instead of
  deleting it.
- `## What's Inside` must list every piece of the group, including ones deployed through
  app-of-apps instead of Terraform. Those are part of the group, not a dependency.

## Style

These rules apply to inline code comments too, not just Markdown.

**The most important styler rule**: Write the fewest characters possible while keeping it
readable and not losing useful information.

- Never join list items with slashes (e.g. `dev`/`staging`/`prod` or
  `aws_eks_cluster`/`aws_eks_cluster_auth`). Use commas and "and" instead (e.g. `dev`, `staging`,
  and `prod`).
- Never use `;`, `-`, or an em dash (`—`) in the middle of a sentence. Use commas, parentheses, or
  split into two sentences instead.
- Never join two independent clauses with a comma (comma splice, e.g. "See the issue, there's no
  fix yet"). Split into two sentences instead.
- Avoid long paragraphs that cram multiple distinct ideas into one block. Break each idea into its
  own short sentence or paragraph.
- Never number a `###` header or bold lead-in for a sequence of steps (e.g.
  `### 1. Create a Feature Branch`). Drop the number, order is implied by document flow. A short
  flat sequence of one-liners can still be a plain numbered markdown list.
