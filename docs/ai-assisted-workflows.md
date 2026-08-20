# AI-Assisted Workflows

This guide walks you through three levels of autonomy for Claude Code in this repo: RPI (research, plan, implement) run manually, TDD (test-driven development) run in auto mode, and QRSPI (questions, research, specification, plan, implementation) run fully autonomous.

## RPI Manual Mode

Default. Every edit and Bash command outside [`.claude/settings.json`](../.claude/settings.json)'s allow-list prompts for approval.

**Step by step:**
- **Research**: point Claude at the file paths you already know, or let it explore the codebase. Nothing runs without your approval either way.
- **Plan**: enter [plan mode](https://code.claude.com/docs/en/permission-modes.md), review the plan, and approve it before Claude touches anything.
- **Implement**: approve or deny each edit and each Bash command individually as Claude works through the change.

**Use when:** the code is unfamiliar, or you want to review every change before it lands.

## TDD Auto Mode

For work you can hand off unattended once a specific test proves the goal is met.

**Step by step:**
- Run [`/goal`](https://code.claude.com/docs/en/goal.md) and define a specific, checkable test as the completion condition, for example a command exiting 0 or a resource reaching a given state.
- Run [`/loop`](https://code.claude.com/docs/en/scheduled-tasks.md) with specific instructions on how to reach the goal.

**Note:** if the goal requires changing the live EKS cluster, feed `/loop` the GitOps loop in [`working_against_live_cluster.md`](https://github.com/ConsciousML/argocd-app-of-apps-template/blob/main/docs/agents/working_against_live_cluster.md) (`argocd-app-of-apps-template`) as its starting instructions. It covers editing, committing, syncing the affected ArgoCD app, and verifying against live cluster state instead of a rendered manifest.

**Use when:** the desired end state is easy to check mechanically but tedious to babysit step by step.

## QRSPI Autonomous Mode

Heaviest workflow, for changes safe to leave unattended because verification is unambiguous enough to loop on.

**Step by step:**
- **Questions**: write down the assumptions the task rests on, the ones that would change the approach if wrong.
- **Research**: falsify them by running code, experimenting, asking, or searching, not guessing.
- **Specification**: capture the validated outcome as a concrete spec.
- **Plan**: break the spec into vertical slices, each with a clear verification criterion.
- **Implementation**: work the slices with [`/goal`](https://code.claude.com/docs/en/goal.md) and [`/loop`](https://code.claude.com/docs/en/scheduled-tasks.md), spawning subagents in parallel per slice.

**Adversarial pair per slice:** one subagent builds, another independently reviews and pushes for simplification. An agent reviewing its own work tends to rationalize it. A separate reviewer, with no stake in the implementation, catches what the builder misses.

**Precondition:** each slice needs a pass or fail check that doesn't require human judgment, such as a specific test or command succeeding. If judging success still needs a person, keep a human in the loop instead of looping autonomously.

**Use when:** work decomposes into independently verifiable slices, for example a bulk migration across similar units, or a well-specified feature with one clear pass criterion.

## Permission Settings

All three modes read the same [`.claude/settings.json`](../.claude/settings.json), but manual and auto mode apply it differently:
- **Manual mode**: only `permissions.allow` entries skip the approval prompt. Everything else prompts.
- **Auto mode**: `permissions.deny` and `permissions.ask` still gate first, blocking or prompting unconditionally. Anything not caught by either falls to Claude's own [auto mode classifier](https://code.claude.com/docs/en/auto-mode-config), which decides what's safe to run on its own.

A few entries are worth calling out because they aren't obvious from the file itself:
- `git push` is on the allow-list because both repos' `main` branches are protected by GitHub rulesets. A PR plus passing CI is required to merge, so a stray push can't land bad code directly.
- `.env` is denied both as a direct read and inside any allowed command run against it (e.g. `cat .env`), closing that leak path.
- `.claude/**` denies edits and writes but allows reads, so Claude can't touch its own guardrails in any mode.

## Origin

The RPI and QRSPI patterns here are adapted from [Tyler Burleigh's writeup](https://tylerburleigh.com/blog/2026/02/22/).
