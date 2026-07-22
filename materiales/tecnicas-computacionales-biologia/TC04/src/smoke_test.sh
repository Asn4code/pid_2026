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

required=(bash uname pwd mkdir touch cp mv ls wc grep tr head sha256sum mktemp)
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
    printf 'El checksum de datos/mini.txt no coincide.\n' >&2
    exit 1
fi

sandbox=$(mktemp -d "${TMPDIR:-/tmp}/tc04-smoke.XXXXXX")
cleanup() {
    rm -rf -- "$sandbox"
}
trap cleanup EXIT HUP INT TERM

mkdir -p -- "$sandbox/espacio con espacios"/{datos,notas,resultados}
cp -- "$data_dir/mini.txt" "$sandbox/espacio con espacios/datos/"
copia="$sandbox/espacio con espacios/datos/mini.txt"

# La estructura mínima está equilibrada: 2 aperturas y 2 cierres.
estructura=$(tr -d '[:space:]' < "$copia")
aperturas=$(tr -cd '(' <<< "$estructura" | wc -c | tr -d ' ')
cierres=$(tr -cd ')' <<< "$estructura" | wc -c | tr -d ' ')
test "$aperturas" -eq 2
test "$cierres" -eq 2

# Un array de Bash funciona como pila: push de tres, pop de uno, quedan dos.
pila=()
pila+=(a); pila+=(b); pila+=(c)
unset 'pila[${#pila[@]}-1]'
test "${#pila[@]}" -eq 2

mkdir -p -- "$(dirname -- "$report")"
data_sha256=$(sha256sum "$copia")
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
    printf 'aperturas\t2\n'
    printf 'pila_tras_pop\t2\n'
} > "$report"

printf 'Informe: %s\n' "$report"
printf 'TC04_SMOKE_TEST_OK\n'
