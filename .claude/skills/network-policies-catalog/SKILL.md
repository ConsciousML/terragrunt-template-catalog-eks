---
name: network-policies-catalog
description: Write or edit a CiliumNetworkPolicy. Use when building a feature that introduces a new namespace, or a new component in an existing namespace, and when editing an existing NetworkPolicy.
---

Follow [`docs/network-policies.md`](../../../docs/network-policies.md) for the concepts and the
build-unrestricted-then-lock-down loop (capture traffic with `hubble`, write the rules, turn
deny-on, re-verify with `hubble observe --verdict DROPPED`).

Match existing policies' shape and scoping (`endpointSelector`, label choice, ingress/egress
split), don't invent a new pattern.
