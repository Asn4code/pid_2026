#!/usr/bin/env bash
set -euo pipefail

temporary=$(mktemp -d)
trap 'rm -rf -- "$temporary"' EXIT
printf 'ACGT\n' > "$temporary/input.txt"

show_arguments() {
  (( $# == 2 )) || return 64
  printf '%s\t%s\n' "$1" "$2"
}

[[ $(show_arguments alpha beta) == $'alpha\tbeta' ]]
if show_arguments only_one >/dev/null 2>&1; then exit 1; fi
[[ $(basename -- "$temporary/input.txt") == input.txt ]]
[[ $(sha256sum "$temporary/input.txt" | LC_ALL=C gawk '{print length($1)}') -eq 64 ]]
printf 'BASH_RECOVERY_OK\tfunctions=ok\targuments=ok\tpaths=ok\tstatus=ok\n'
