#!/usr/bin/env bash
set -euo pipefail

for tool in bash gawk sha256sum cp mkdir mktemp mv grep find sort xargs head cmp; do
  command -v "$tool" >/dev/null 2>&1 || { printf 'MISSING\t%s\n' "$tool" >&2; exit 1; }
done

# No basta con encontrar cmp: el comprobador publico necesita que distinga
# igualdad y diferencia. La prueba funcional detecta ejecutables hostiles.
cmp_probe=$(mktemp -d)
trap 'rm -rf -- "$cmp_probe"' EXIT
printf 'tc07\n' > "$cmp_probe/left"
printf 'tc07\n' > "$cmp_probe/equal"
printf 'TC07\n' > "$cmp_probe/different"
cmp -s "$cmp_probe/left" "$cmp_probe/equal" || { printf 'BROKEN\tcmp_equal\n' >&2; exit 1; }
if cmp -s "$cmp_probe/left" "$cmp_probe/different"; then
  printf 'BROKEN\tcmp_difference\n' >&2
  exit 1
fi
rm -rf -- "$cmp_probe"
trap - EXIT

bash_version=${BASH_VERSION%%(*}
gawk_version=$(gawk --version | LC_ALL=C gawk 'NR==1{gsub(/,/, "", $3); print $3}')
printf 'ENVIRONMENT_OK\tbash=%s\tgawk=%s\ttools=available\tnetwork=not-required\n' \
  "$bash_version" "$gawk_version"
