# k8s-rbac-least-privilege

A small, namespaced RBAC setup for a workload that only needs to read one
ConfigMap and its own Pods. It shows the pieces that are easy to get wrong:

- a dedicated ServiceAccount per workload (never `default`)
- a `Role` scoped by `resourceNames`, with no wildcards
- a `RoleBinding`, not a `ClusterRoleBinding`
- token automounting off at the ServiceAccount, switched on only where used

## Layout

| Path | What it is |
| --- | --- |
| `manifests/` | Namespace, ServiceAccount, Role, RoleBinding, Deployment |
| `scripts/check-rbac.sh` | Rejects wildcard rules and cluster-wide bindings |

## Usage

```sh
kubectl apply -f manifests/
kubectl auth can-i get configmap/app-config \
  --as=system:serviceaccount:rbac-demo:app-reader -n rbac-demo
```

## Validation

```sh
make validate
```

This runs, in order:

1. `kubeconform -strict` over `manifests/` (schema check, no cluster needed)
2. `scripts/check-rbac.sh`, which rejects wildcard rules, ClusterRoleBindings
   and any binding to `cluster-admin`
3. `scripts/test-check-rbac.sh`, which proves the check fails on bad input
4. `shellcheck` over `scripts/`

The same target runs in CI. Needs `kubeconform` and `shellcheck` on PATH.

## Caveats

- `check-rbac.sh` is line-based and assumes the one-line list style used in
  `manifests/`. It is a guard rail, not a policy engine.
- Nothing here talks to a cluster, so `kubectl auth can-i` in the usage
  section is a manual check.
