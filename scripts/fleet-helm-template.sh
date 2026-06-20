#!/usr/bin/env bash
# Render Kubernetes manifests from a Fleet helm bundle (fleet.yaml + optional valuesFiles).
# Used by Fleet PR CI to diff helm chart output without a cluster.
set -euo pipefail

bundle_dir="${1:?bundle directory (contains fleet.yaml)}"
fleet_yaml="${bundle_dir}/fleet.yaml"

if [[ ! -f "$fleet_yaml" ]]; then
  echo "fleet.yaml not found in ${bundle_dir}" >&2
  exit 1
fi

if ! command -v helm >/dev/null 2>&1; then
  echo "helm is not installed" >&2
  exit 1
fi

values_file="$(mktemp)"
trap 'rm -f "$values_file"' EXIT

python3 - "$fleet_yaml" "$bundle_dir" "$values_file" <<'PY'
import json
import os
import subprocess
import sys

import yaml

fleet_yaml, bundle_dir, values_file = sys.argv[1], sys.argv[2], sys.argv[3]
with open(fleet_yaml, encoding="utf-8") as f:
    doc = yaml.safe_load(f) or {}

helm = doc.get("helm") or {}
chart = helm.get("chart") or ""
repo = helm.get("repo") or ""
version = helm.get("version") or ""
release = helm.get("releaseName") or ""
namespace = doc.get("defaultNamespace") or doc.get("namespace") or "default"
values = helm.get("values") or {}

if not release:
    if chart.startswith("oci://"):
        release = os.path.basename(chart.rstrip("/")) or "release"
    else:
        release = chart or "release"

with open(values_file, "w", encoding="utf-8") as f:
    yaml.dump(values, f, default_flow_style=False)

helm_args = ["helm", "template", release]

if chart.startswith("oci://"):
    helm_args.append(chart)
elif repo and chart:
    helm_args.extend([chart, "--repo", repo])
elif chart:
    helm_args.append(chart)
else:
    print("fleet.yaml helm.chart is not set", file=sys.stderr)
    sys.exit(1)

if version:
    helm_args.extend(["--version", version])

helm_args.extend(["--namespace", namespace, "-f", values_file])

for vf in helm.get("valuesFiles") or []:
    path = os.path.join(bundle_dir, vf)
    if not os.path.isfile(path):
        print(f"valuesFiles entry not found: {path}", file=sys.stderr)
        sys.exit(1)
    helm_args.extend(["-f", path])

subprocess.run(helm_args, check=True)
PY
