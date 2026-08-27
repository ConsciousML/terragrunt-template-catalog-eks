---
name: reproducibility-catalog
description: Regenerate provider lock files after adding a unit or changing a provider version/constraint under units/. Use before considering such a change done.
---

Follow [`docs/reproducibility.md`](../../../docs/reproducibility.md) for the steps. Run it
unprompted whenever a change adds, removes, or bumps a provider requirement, don't wait for CI or
the user to notice a stale lock file.
