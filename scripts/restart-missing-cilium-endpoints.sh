#!/bin/sh
set -eu

# Cilium only manages pods created after cilium-agent is already running on their node, so
# every pod predating it (the entire EKS bootstrap) has no CiliumEndpoint and stays invisible
# to Hubble and any CiliumNetworkPolicy enforcement. See docs/monitoring.md.
#
# Restarts every Deployment/StatefulSet/DaemonSet with a pod missing a CiliumEndpoint, waits
# for every rollout, then re-scans and fails if any is still missing one.
#
# Same script as the one baked into argocd-app-of-apps-template's
# manifests/cilium-restart-job ConfigMap (which runs it as a one-shot Job on cluster bootstrap);
# kept in sync manually since it must stay POSIX sh to run in that Job's Alpine container.
#
# Warning: restarting deletes and recreates pods. Run only during a maintenance window.

log_info() { echo "[INFO] $*" >&2; }
log_error() { echo "[ERROR] $*" >&2; }

find_missing() {
  for ns in $(kubectl get ns -o jsonpath='{.items[*].metadata.name}'); do
    ceps=$(kubectl -n "$ns" get ciliumendpoints.cilium.io -o jsonpath='{.items[*].metadata.name}' 2>/dev/null)
    pods=$(kubectl -n "$ns" get pod -o custom-columns=NAME:.metadata.name,HOST:.spec.hostNetwork --no-headers 2>/dev/null \
      | awk '$2 == "<none>" || $2 == "false" {print $1}')
    for pod in $pods; do
      case " $ceps " in
        *" $pod "*) continue ;;
      esac
      kind=$(kubectl -n "$ns" get pod "$pod" -o jsonpath='{.metadata.ownerReferences[0].kind}')
      name=$(kubectl -n "$ns" get pod "$pod" -o jsonpath='{.metadata.ownerReferences[0].name}')
      if [ "$kind" = "ReplicaSet" ]; then
        kind=$(kubectl -n "$ns" get replicaset "$name" -o jsonpath='{.metadata.ownerReferences[0].kind}')
        name=$(kubectl -n "$ns" get replicaset "$name" -o jsonpath='{.metadata.ownerReferences[0].name}')
      fi
      echo "${ns}/${kind}/${name:-$pod}"
    done
  done | sort -u
}

restartable_targets() {
  while IFS=/ read -r ns kind name; do
    [ -z "$ns" ] && continue
    case "$kind" in
      Deployment | StatefulSet | DaemonSet) ;;
      *) continue ;;
    esac
    echo "${ns}/${kind}/${name}"
  done
}

log_info "Scanning for pods missing a CiliumEndpoint"
missing=$(find_missing)

if [ -z "$missing" ]; then
  log_info "No pods missing a CiliumEndpoint, nothing to do"
  exit 0
fi

printf '%s\n' "$missing" | while IFS= read -r line; do
  log_info "Missing CiliumEndpoint: $line"
done

targets=$(printf '%s\n' "$missing" | restartable_targets)

printf '%s\n' "$missing" | while IFS=/ read -r ns kind name; do
  [ -z "$ns" ] && continue
  case "$kind" in
    Deployment | StatefulSet | DaemonSet) ;;
    *) log_info "Skipping $ns/${name:-?}: $kind is not something rollout restart can roll" ;;
  esac
done

printf '%s\n' "$targets" | while IFS=/ read -r ns kind name; do
  [ -z "$ns" ] && continue
  lkind=$(printf '%s' "$kind" | tr '[:upper:]' '[:lower:]')
  log_info "Restarting $ns/$kind/$name"
  kubectl -n "$ns" rollout restart "${lkind}/${name}"
done

printf '%s\n' "$targets" | while IFS=/ read -r ns kind name; do
  [ -z "$ns" ] && continue
  lkind=$(printf '%s' "$kind" | tr '[:upper:]' '[:lower:]')
  log_info "Waiting for rollout: $ns/$kind/$name (timeout 10m)"
  kubectl -n "$ns" rollout status "${lkind}/${name}" --timeout=10m
done

log_info "Re-checking for pods still missing a CiliumEndpoint"
still_missing=$(find_missing)
still_missing_targets=$(printf '%s\n' "$still_missing" | restartable_targets)

printf '%s\n' "$still_missing" | while IFS=/ read -r ns kind name; do
  [ -z "$ns" ] && continue
  case "$kind" in
    Deployment | StatefulSet | DaemonSet) log_error "Still missing CiliumEndpoint: $ns/$kind/$name" ;;
    *) log_info "Still missing CiliumEndpoint (not actionable): $ns/$kind/${name:-?}" ;;
  esac
done

if [ -n "$still_missing_targets" ]; then
  log_error "Restart did not resolve all missing CiliumEndpoints"
  exit 1
fi

log_info "Done, no pods missing a CiliumEndpoint"
