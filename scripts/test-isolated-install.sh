#!/usr/bin/env bash
set -euo pipefail

project_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)
archive="$project_root/build/jsoupLink-1.1.1.paclet"
official_archive="$project_root/build/jsoupLink-1.0.0-official.paclet"
normal_userbase=$(WolframKernel -noinit -noprompt -run 'WriteString[$Output,$UserBaseDirectory];Exit[0]')
licensing_source="$normal_userbase/Licensing"

if [[ ! -f "$archive" ]]; then
  echo "Missing $archive; run ./scripts/build.wls first." >&2
  exit 1
fi
if [[ ! -d "$licensing_source" ]]; then
  echo "Missing Wolfram licensing directory: $licensing_source" >&2
  exit 1
fi

run_kernel() {
  local userbase=$1
  shift
  WOLFRAM_USERBASE="$userbase" WolframKernel -noinit -noprompt -script "$@"
}

prepare_userbase() {
  local userbase=$1
  mkdir -p "$userbase"
  ln -s "$licensing_source" "$userbase/Licensing"
}

empty_userbase=$(mktemp -d /tmp/jsouplink-empty-userbase.XXXXXX)
upgrade_userbase=$(mktemp -d /tmp/jsouplink-upgrade-userbase.XXXXXX)
trap 'rm -rf -- "$empty_userbase" "$upgrade_userbase"' EXIT
prepare_userbase "$empty_userbase"
prepare_userbase "$upgrade_userbase"

run_kernel "$empty_userbase" "$project_root/scripts/isolated-smoke.wls" "$archive"
run_kernel "$empty_userbase" "$project_root/scripts/isolated-verify.wls"

if [[ ! -f "$official_archive" ]]; then
  curl -fL --retry 3 -o "$official_archive" https://github.com/cekdahl/jSoupLink/releases/download/1.0.0/jsoupLink-1.0.0.paclet
fi
run_kernel "$upgrade_userbase" "$project_root/scripts/install-official-1.0.wls" "$official_archive"
run_kernel "$upgrade_userbase" "$project_root/scripts/isolated-smoke.wls" "$archive"
run_kernel "$upgrade_userbase" "$project_root/scripts/isolated-verify.wls"

echo "Both isolated installation scenarios passed."
