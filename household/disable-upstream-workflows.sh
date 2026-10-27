#!/usr/bin/env bash
# Disable every GitHub Actions workflow in the fork except the household-* ones.
# Safe to run any number of times (e.g. after each rebase onto a new upstream tag,
# which can bring in new upstream workflows).
set -euo pipefail

REPO="${1:-singh-taranjeet/immich}"

gh workflow list --repo "$REPO" --all --limit 500 --json name,id,state,path \
  --jq '.[] | [.id, .state, .path, .name] | @tsv' |
while IFS=$'\t' read -r id state path name; do
  file="${path##*/}"
  if [[ "$file" == household-* ]]; then
    if [[ "$state" != "active" ]]; then
      echo "enable   $file ($name)"
      gh workflow enable "$id" --repo "$REPO" </dev/null
    else
      echo "keep     $file ($name)"
    fi
  elif [[ "$state" == "active" ]]; then
    echo "disable  $file ($name)"
    gh workflow disable "$id" --repo "$REPO" </dev/null || echo "  (could not disable $file)"
  else
    echo "already  $file ($name) [$state]"
  fi
done
