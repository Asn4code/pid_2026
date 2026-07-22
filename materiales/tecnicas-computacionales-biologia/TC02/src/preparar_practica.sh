#!/usr/bin/env bash
set -euo pipefail

if (($# != 1)); then
    printf 'Uso: %s DIRECTORIO_NUEVO\n' "$(basename "$0")" >&2
    exit 2
fi

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
practice_dir=$(cd -- "$script_dir/.." && pwd -P)
destination=$1

if [[ -e "$destination" ]]; then
    printf 'El destino ya existe; no se modificará: %s\n' "$destination" >&2
    exit 1
fi

(
    cd -- "$practice_dir/datos"
    sha256sum -c SHA256SUMS >/dev/null
    sha256sum -c MANIFEST.sha256 >/dev/null
)

mkdir -p -- "$destination"/{datos,scripts,resultados,notas}
cp -a -- "$practice_dir/datos/corpus/." "$destination/datos/"
cp -- "$practice_dir/datos/caso.fasta" "$destination/datos/"
cp -- "$practice_dir/entrega/plantilla_pruebas.tsv" "$destination/pruebas.tsv"
cp -- "$practice_dir/entrega/plantilla_README.md" "$destination/notas/README.md"
touch -- "$destination/notas/history.txt"

printf 'Proyecto individual preparado: %s\n' "$destination"
printf 'Datos: 5 FASTA multilínea y caso.fasta\n'
printf 'TC02_STARTER_OK\n'
