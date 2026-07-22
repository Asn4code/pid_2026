#!/usr/bin/env bash
set -euo pipefail

if (($# > 1)); then
    printf 'Uso: %s [DIRECTORIO_PROYECTO]\n' "$(basename "$0")" >&2
    exit 2
fi

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
practice_dir=$(cd -- "$script_dir/.." && pwd -P)
project=${1:-.}
project=$(cd -- "$project" && pwd -P)

programs=(transcribir.sh longitudes.sh gc.sh)
for program in "${programs[@]}"; do
    path="$project/scripts/$program"
    if [[ ! -f "$path" ]]; then
        printf 'Falta scripts/%s\n' "$program" >&2
        exit 1
    fi
    bash -n "$path"
done

case_dir=$(mktemp -d "${TMPDIR:-/tmp}/tc02-submission.XXXXXX")
cleanup() {
    rm -rf -- "$case_dir"
}
trap cleanup EXIT HUP INT TERM

fixture="$case_dir/corpus"
mkdir -p -- "$fixture"
cp -a -- "$practice_dir/datos/corpus/." "$fixture/"
cp -- "$practice_dir/datos/caso.fasta" "$fixture/"

# ---------------------------------------------------------------------------
# Programa 1: transcribir ADN -> ARN con sed, sin tocar las cabeceras
# ---------------------------------------------------------------------------
program1="$project/scripts/transcribir.sh"
out=$(bash "$program1" "$fixture/caso.fasta" 2>/dev/null)
# En las líneas de secuencia no puede quedar ninguna T.
if grep -v '^>' <<< "$out" | grep -q 'T'; then
    printf 'transcribir.sh dejó una T en una línea de secuencia.\n' >&2
    exit 1
fi
# Deben aparecer 8 U (una por cada T transcrita del caso).
test "$(grep -v '^>' <<< "$out" | tr -cd 'U' | wc -c | tr -d ' ')" -eq 8
# Las cabeceras se conservan intactas.
grep -q '^>caso_uno sintetica$' <<< "$out"
grep -q '^>caso_dos sintetica$' <<< "$out"
if bash "$program1" "$case_dir/no_existe.fasta" >/dev/null 2>&1; then
    printf 'transcribir.sh no falla con un fichero inexistente.\n' >&2
    exit 1
fi
printf 'transcribir\tOK\n'

# ---------------------------------------------------------------------------
# Programa 2: longitud de cada secuencia FASTA (multilínea) con awk
# ---------------------------------------------------------------------------
program2="$project/scripts/longitudes.sh"
out=$(bash "$program2" "$fixture/adn_3.fasta")
grep -q $'^adn_3\t34$' <<< "$out"
out=$(bash "$program2" "$fixture/caso.fasta")
grep -q $'^caso_uno\t16$' <<< "$out"
grep -q $'^caso_dos\t16$' <<< "$out"
if bash "$program2" "$case_dir/no_existe.fasta" >/dev/null 2>&1; then
    printf 'longitudes.sh no falla con un fichero inexistente.\n' >&2
    exit 1
fi
printf 'longitudes\tOK\n'

# ---------------------------------------------------------------------------
# Programa 3: contenido GC de cada secuencia (multilínea) con awk
# ---------------------------------------------------------------------------
program3="$project/scripts/gc.sh"
out=$(bash "$program3" "$fixture/adn_3.fasta")
grep -q $'^adn_3\t32\t34\t94.1$' <<< "$out"
out=$(bash "$program3" "$fixture/adn_2.fasta")
grep -q $'^adn_2\t0\t20\t0.0$' <<< "$out"
if bash "$program3" "$case_dir/no_existe.fasta" >/dev/null 2>&1; then
    printf 'gc.sh no falla con un fichero inexistente.\n' >&2
    exit 1
fi
printf 'gc\tOK\n'

printf 'TC02_SUBMISSION_TESTS_OK\n'
