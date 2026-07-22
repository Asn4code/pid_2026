#!/usr/bin/env bash
set -euo pipefail

usage() {
    printf 'Uso: %s [--report RUTA]\n' "$(basename "$0")"
}

report="resultados/smoke_test.tsv"
while (($#)); do
    case "$1" in
        --report)
            if (($# < 2)); then
                printf 'Falta la ruta después de --report.\n' >&2
                exit 2
            fi
            report=$2
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            printf 'Argumento no reconocido: %s\n' "$1" >&2
            usage >&2
            exit 2
            ;;
    esac
done

required=(bash uname pwd mkdir touch cp mv ls wc sort grep sha256sum mktemp)
for program in "${required[@]}"; do
    if ! command -v "$program" >/dev/null 2>&1; then
        printf 'Falta la orden requerida: %s\n' "$program" >&2
        exit 1
    fi
done

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
practice_dir=$(cd -- "$script_dir/.." && pwd -P)
data_dir="$practice_dir/datos"

if ! (cd -- "$data_dir" && sha256sum -c SHA256SUMS >/dev/null); then
    printf 'El checksum de datos/mini_ordenada.txt no coincide.\n' >&2
    exit 1
fi

sandbox=$(mktemp -d "${TMPDIR:-/tmp}/tc02-smoke.XXXXXX")
cleanup() {
    rm -rf -- "$sandbox"
}
trap cleanup EXIT HUP INT TERM

mkdir -p -- "$sandbox/espacio con espacios"/{datos,notas,resultados}
cp -- "$data_dir/mini_ordenada.txt" "$sandbox/espacio con espacios/datos/"
touch -- "$sandbox/espacio con espacios/notas/setup_ok.txt"
cp -- "$sandbox/espacio con espacios/notas/setup_ok.txt" \
    "$sandbox/espacio con espacios/resultados/copia.txt"
mv -- "$sandbox/espacio con espacios/resultados/copia.txt" \
    "$sandbox/espacio con espacios/resultados/entorno_comprobado.txt"

test -f "$sandbox/espacio con espacios/datos/mini_ordenada.txt"
test -f "$sandbox/espacio con espacios/resultados/entorno_comprobado.txt"
lineas=$(wc -l < "$sandbox/espacio con espacios/datos/mini_ordenada.txt")
test "$lineas" -eq 7

# La lista debe estar ordenada de forma ascendente: requisito de la búsqueda binaria.
LC_ALL=C sort -c -n "$sandbox/espacio con espacios/datos/mini_ordenada.txt"

# Comprobación de que la aritmética entera de Bash (recuento de operaciones) funciona.
suma=0
for valor in $(cat "$sandbox/espacio con espacios/datos/mini_ordenada.txt"); do
    suma=$((suma + 1))
done
test "$suma" -eq 7

mkdir -p -- "$(dirname -- "$report")"
data_sha256=$(sha256sum "$data_dir/mini_ordenada.txt")
data_sha256=${data_sha256%% *}
{
    printf 'field\tvalue\n'
    printf 'status\tOK\n'
    printf 'test_version\t0.1.0\n'
    printf 'timestamp_utc\t%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    printf 'kernel\t%s\n' "$(uname -s)"
    printf 'bash_version\t%s\n' "${BASH_VERSION}"
    printf 'working_directory\t%s\n' "$(pwd -P)"
    printf 'data_sha256\t%s\n' "$data_sha256"
    printf 'data_lines\t7\n'
} > "$report"

printf 'Informe: %s\n' "$report"
printf 'TC03_SMOKE_TEST_OK\n'
