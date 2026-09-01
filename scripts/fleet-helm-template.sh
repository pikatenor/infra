#!/usr/bin/env bash
# Render Kubernetes manifests from a Fleet helm bundle (fleet.yaml + optional valuesFiles).
# Used by Fleet PR CI to diff helm chart output without a cluster.
_lib="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/ci/lib.sh"
if [[ -r "$_lib" ]]; then
  . "$_lib"
else
  set -euo pipefail
fi

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
    # Fleet supports go-getter git chart URLs (e.g.
    # github.com/owner/repo//path/to/chart?ref=v1.2.3), but `helm template`
    # does not. Fetch the chart into a local dir first.
    if "//" in chart and not chart.startswith(("./", "../", "/")):
        import tempfile

        repo_part, _, subpath = chart.partition("//")
        subpath, _, query = subpath.partition("?")
        ref = ""
        for param in query.split("&"):
            if param.startswith("ref="):
                ref = param[len("ref="):]
                break

        tmpdir = tempfile.mkdtemp(prefix="fleet-helm-chart-")
        clone_cmd = ["git", "clone", "--depth", "1"]
        if ref:
            clone_cmd.extend(["--branch", ref])
        clone_cmd.extend(["https://" + repo_part, tmpdir])
        print("+ " + " ".join(clone_cmd), file=sys.stderr)
        clone = subprocess.run(clone_cmd, capture_output=True, text=True)
        if clone.returncode != 0:
            print(clone.stdout, file=sys.stderr, end="")
            print(clone.stderr, file=sys.stderr, end="")
            print(
                f"git clone failed (exit {clone.returncode}) for chart {chart}",
                file=sys.stderr,
            )
            sys.exit(clone.returncode)
        chart = os.path.join(tmpdir, subpath)
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

print("+ " + " ".join(helm_args), file=sys.stderr)
proc = subprocess.run(helm_args)
if proc.returncode != 0:
    print(f"helm template failed (exit {proc.returncode})", file=sys.stderr)
    sys.exit(proc.returncode)
PY
