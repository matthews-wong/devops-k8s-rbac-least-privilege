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

Filled in as the checks land.
