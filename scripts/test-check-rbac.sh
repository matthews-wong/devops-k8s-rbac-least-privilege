#!/bin/sh
# Feed check-rbac.sh known-bad manifests and require it to fail on each,
# then require it to pass on the real ones.
set -eu

cd "$(dirname "$0")/.."

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

expect_fail() {
  name="$1" body="$2"
  printf '%s\n' "$body" > "$tmpdir/$name.yaml"
  if scripts/check-rbac.sh "$tmpdir/$name.yaml" >/dev/null 2>&1; then
    echo "FAIL: $name was accepted" >&2
    exit 1
  fi
  echo "ok: $name rejected"
}

expect_fail wildcard-verbs 'rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["*"]'
expect_fail wildcard-resources "rules:
  - apiGroups: ['']
    resources: ['*']
    verbs: [get]"
expect_fail cluster-binding 'kind: ClusterRoleBinding'
expect_fail cluster-admin 'roleRef:
  kind: ClusterRole
  name: cluster-admin'

scripts/check-rbac.sh >/dev/null
echo "ok: shipped manifests accepted"
