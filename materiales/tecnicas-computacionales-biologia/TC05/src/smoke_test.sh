#!/usr/bin/env bash
# smoke_test.sh [--report RUTA]
# Prueba mínima de extremo a extremo del entorno de la práctica TC05:
# comprueba las órdenes requeridas, el checksum de los datos y que un array
# asociativo de Bash (la base de una tabla hash) funciona.
set -euo pipefail

usage() { printf 'Uso: %s [--report RUTA]\n' "$(basename "$0")"; }

report="resultados/smoke_test.tsv"
while (($#)); do
    case "$1" in
        --report)
            (($# < 2)) && { printf 'Falta la ruta después de --report.\n' >&2; exit 2; }
            report=$2; shift 2 ;;
        -h|--help) usage; exit 0 ;;
        *) printf 'Argumento no reconocido: %s\n' "$1" >&2; usage >&2; exit 2 ;;
    esac
done

required=(bash uname pwd mkdir cp ls wc grep tr sort head sed sha256sum mktemp date)
for program in "${required[@]}"; do
    if ! command -v "$program" >/dev/null 2>&1; then
        printf 'Falta la orden requerida: %s\n' "$program" >&2
        exit 1
    fi
done

# Requiere Bash 4+ por los arrays asociativos (tabla hash).
if ((BASH_VERSINFO[0] < 4)); then
    printf 'Se requiere Bash 4 o superior (arrays asociativos).\n' >&2
    exit 1
fi

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
practice_dir=$(cd -- "$script_dir/.." && pwd -P)
data_dir="$practice_dir/datos"

if ! (cd -- "$data_dir" && sha256sum -c SHA256SUMS >/dev/null); then
    printf 'El checksum de los datos no coincide.\n' >&2
    exit 1
fi

# Prueba de tabla hash: un array asociativo cuenta bases de una secuencia.
declare -A conteo
for base in A T G C A A; do
    conteo[$base]=$(( ${conteo[$base]:-0} + 1 ))
done
test "${conteo[A]}" -eq 3
test "${#conteo[@]}" -eq 4

mkdir -p -- "$(dirname -- "$report")"
sha=$(sha256sum "$data_dir/mini.txt"); sha=${sha%% *}
{
    printf 'field\tvalue\n'
    printf 'status\tOK\n'
    printf 'test_version\t0.1.0\n'
    printf 'timestamp_utc\t%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    printf 'kernel\t%s\n' "$(uname -s)"
    printf 'bash_version\t%s\n' "${BASH_VERSION}"
    printf 'working_directory\t%s\n' "$(pwd -P)"
    printf 'data_sha256\t%s\n' "$sha"
    printf 'conteo_A\t3\n'
    printf 'bases_distintas\t4\n'
} > "$report"

printf 'Informe: %s\n' "$report"
printf 'TC05_SMOKE_TEST_OK\n'
