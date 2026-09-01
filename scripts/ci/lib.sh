# shellcheck shell=bash
# Shared bash preamble for GitHub Actions steps in this repo.
#
# Usage (inside a `run: |` block, after actions/checkout):
#   . "$GITHUB_WORKSPACE/scripts/ci/lib.sh" || exit 1
#
# Replaces a bare `set -euo pipefail`, which aborts steps without saying where
# or why. The ERR trap below annotates the failing line, the expanded command,
# and surrounding source context so the job log is readable on its own.

set -Eeuo pipefail

ci_group() { echo "::group::$*"; }
ci_endgroup() { echo "::endgroup::"; }
ci_error() { echo "::error::$*" >&2; }
ci_warn() { echo "::warning::$*" >&2; }

# ci_log <message...> -- plain progress line, prefixed so it stands out.
ci_log() { echo ">> $*"; }

# ci_run <command...> -- echo the command, then run it.
ci_run() {
  echo "+ $*" >&2
  "$@"
}

# ci_dump <title> <file> [max_bytes] -- fold a captured output file into the log.
# Output captured into files for the step summary is otherwise invisible in the
# job log, which is the main reason failures here are hard to read.
ci_dump() {
  local title="$1" file="$2" max="${3:-20000}"
  if [[ ! -s "$file" ]]; then
    ci_log "${title}: no output"
    return 0
  fi
  ci_group "$title"
  tail -c "$max" "$file"
  echo
  ci_endgroup
}

ci_on_err() {
  local code="$1" line="$2" cmd="$3" src="${4:-}" opts="${5:-}"

  # Bash runs the ERR trap even while errexit is off, so a handled failure
  # inside a `set +e` region (e.g. kubediff exiting 1 for "changes detected")
  # would otherwise be reported as a step failure. Only report when errexit is
  # active, i.e. when this failure really does abort the step.
  [[ "$opts" == *e* ]] || return 0

  # A heredoc command carries its whole body in BASH_COMMAND; keep the first
  # line only so the report stays readable.
  cmd="${cmd%%$'\n'*}"
  if (( ${#cmd} > 200 )); then
    cmd="${cmd:0:200}..."
  fi

  {
    echo
    echo "===== bash aborted ====="
    echo "exit code : ${code}"
    echo "location  : ${src:-<unknown>}:${line}"
    echo "command   : ${cmd}"
    if [[ -n "$src" && -r "$src" ]]; then
      echo "context   :"
      awk -v n="$line" 'NR >= n - 3 && NR <= n + 3 {
        printf "  %s %4d | %s\n", (NR == n ? "->" : "  "), NR, $0
      }' "$src"
    fi
    echo "========================"
    echo
  } >&2

  ci_error "exit ${code} at ${src##*/}:${line}: ${cmd}"
}

trap 'ci_on_err "$?" "$LINENO" "$BASH_COMMAND" "${BASH_SOURCE[0]}" "$-"' ERR
