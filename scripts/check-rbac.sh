#!/bin/sh
# Fail when an RBAC manifest grants more than a namespaced workload needs:
# wildcard verbs/resources/apiGroups, ClusterRoleBindings, or a binding to
# cluster-admin. Line-based on purpose: the manifests use flow-style lists
# on one line, so no YAML parser is required.
#
# Usage: scripts/check-rbac.sh [file...]   (default: manifests/*.yaml)
set -eu

cd "$(dirname "$0")/.."

[ "$#" -gt 0 ] || set -- manifests/*.yaml

WILDCARD_RULE='^[[:space:]]*-?[[:space:]]*(verbs|resources|apiGroups):.*["'"'"']\*["'"'"']'
CLUSTER_BINDING='^kind:[[:space:]]*ClusterRoleBinding'
CLUSTER_ADMIN='^[[:space:]]+name:[[:space:]]*cluster-admin'

# Prints one line per match and returns 1 when anything matched.
scan() {
  file="$1" pattern="$2" message="$3"
  hits="$(grep -nE "$pattern" "$file" || true)"
  [ -n "$hits" ] || return 0
  printf '%s\n' "$hits" | while IFS=: read -r line _; do
    echo "check-rbac: $file:$line: $message" >&2
  done
  return 1
}

fail=0
for f in "$@"; do
  [ -f "$f" ] || { echo "check-rbac: $f not found" >&2; exit 2; }
  scan "$f" "$WILDCARD_RULE" "wildcard in a rule (verbs, resources or apiGroups)" || fail=1
  scan "$f" "$CLUSTER_BINDING" "ClusterRoleBinding grants cluster-wide access; use a RoleBinding" || fail=1
  scan "$f" "$CLUSTER_ADMIN" "binds cluster-admin" || fail=1
done

[ "$fail" -eq 0 ] || exit 1
echo "check-rbac: ok ($# file(s))"
