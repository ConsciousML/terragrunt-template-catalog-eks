# AI-Assisted Workflows

Three levels of autonomy for Claude Code in this repo.

The first two follow the RPI pattern: research, then plan, then implement, with review between each phase. See [Tyler Burleigh's writeup](https://tylerburleigh.com/blog/2026/02/22/) for the fuller version this is adapted from. The third extends it to QRSPI for heavier, unattended work.

## RPI Manual Mode

Default. Every edit and Bash command outside [`.claude/settings.json`](../.claude/settings.json)'s allow-list prompts for approval.

**Step by step:**
- **Research**: point Claude at the file paths you already know, or let it explore the codebase. Nothing runs without your approval either way.
- **Plan**: Enter plan mode, before it touches anything.
- **Implement**: approve or deny each edit and each Bash command individually as Claude works through the change.

**Use when:** the code is unfamiliar, or you want to review every change before it lands.

## RPI Permissive Mode

Edits auto-accept. Bash outside the allow-list still prompts.

**Step by step:**
- **Research**: same as manual mode, exploring the codebase doesn't need approval either way.
- **Plan**: agree on the approach while still in manual mode, since edits stop pausing for review once you switch.
- **Implement**: press `Shift+Tab` to cycle the permission mode to `acceptEdits`, then let Claude apply edits automatically. Bash commands outside the allow-list in `.claude/settings.json` still prompt.

See `.claude/settings.json` for the exact allow and deny rules. A few choices are worth calling out because they aren't obvious from the file itself:
- `git push` is on the allow-list because both repos' `main` branches are protected by GitHub rulesets. A PR plus passing CI is required to merge, so a stray push can't land bad code directly.
- `.env` is denied both as a direct read and inside any allowed command run against it (e.g. `cat .env`), closing that leak path.
- `.claude/**` denies edits and writes but allows reads, so Claude can't touch its own guardrails in any mode.

**Use when:** you know the area, it's a common feature (add a unit, wire a stack, fix a bug), and reviewing at PR-level is more convenient

## QRSPI Autonomous Mode

Heaviest workflow, for changes safe to leave unattended because verification is unambiguous enough to loop on.

**Step by step:**
- **Questions**: write down the assumptions the task rests on, the ones that would change the approach if wrong.
- **Research**: falsify them by running code, experimenting, asking, or searching, not guessing.
- **Specification**: capture the validated outcome as a concrete spec.
- **Plan**: break the spec into vertical slices, each with a clear verification criterion.
- **Implementation**: work the slices with [`/goal`](https://code.claude.com/docs/en/goal) and [`/loop`](https://claude.com/blog/getting-started-with-loops), spawning subagents in parallel per slice.

**Adversarial pair per slice:** one subagent builds, another independently reviews and pushes for simplification. An agent reviewing its own work tends to rationalize it. A separate reviewer, with no stake in the implementation, catches what the builder misses.

**Precondition:** each slice needs a pass or fail check that doesn't require human judgment, such as a specific test or command succeeding. If judging success still needs a person, keep a human in the loop instead of looping autonomously.

**Use when:** work decomposes into independently verifiable slices, for example a bulk migration across similar units, or a well-specified feature with one clear pass criterion.