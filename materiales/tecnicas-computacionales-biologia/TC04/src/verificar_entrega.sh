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

programs=(ventanas.sh pila.sh cola.sh)
for program in "${programs[@]}"; do
    path="$project/scripts/$program"
    if [[ ! -f "$path" ]]; then
        printf 'Falta scripts/%s\n' "$program" >&2
        exit 1
    fi
    bash -n "$path"
done

case_dir=$(mktemp -d "${TMPDIR:-/tmp}/tc04-submission.XXXXXX")
cleanup() {
    rm -rf -- "$case_dir"
}
trap cleanup EXIT HUP INT TERM

fixture="$case_dir/corpus"
mkdir -p -- "$fixture"
cp -a -- "$practice_dir/datos/corpus/." "$fixture/"
cp -- "$practice_dir/datos/caso.fasta" "$practice_dir/datos/caso_estructura.txt" \
      "$practice_dir/datos/caso_ids.txt" "$fixture/"

campo() { sed -n -E "s/^$1: (.*)/\\1/p"; }

# ---------------------------------------------------------------------------
# Programa 1: ventanas deslizantes sobre un array (acceso O(1))
# ---------------------------------------------------------------------------
program1="$project/scripts/ventanas.sh"
out=$(bash "$program1" "$fixture/caso.fasta" 3)
test "$(campo ventanas <<< "$out")" -eq 8
grep -q $'^1\tATG$' <<< "$out"
grep -q $'^8\tCGT$' <<< "$out"
out=$(bash "$program1" "$fixture/secuencia.fasta" 4)
test "$(campo ventanas <<< "$out")" -eq 11
if bash "$program1" "$fixture/caso.fasta" 0 >/dev/null 2>&1; then
    printf 'ventanas.sh no falla con K no válido.\n' >&2
    exit 1
fi
if bash "$program1" "$case_dir/no_existe.fasta" 3 >/dev/null 2>&1; then
    printf 'ventanas.sh no falla con un fichero inexistente.\n' >&2
    exit 1
fi
printf 'ventanas\tOK\n'

# ---------------------------------------------------------------------------
# Programa 2: emparejamiento de bases con una pila (LIFO)
# ---------------------------------------------------------------------------
program2="$project/scripts/pila.sh"
out=$(bash "$program2" "$fixture/estructura_ok.txt")
grep -q '^resultado: equilibrado$' <<< "$out"
test "$(campo profundidad_maxima <<< "$out")" -eq 3
out=$(bash "$program2" "$fixture/estructura_extra_cierre.txt")
grep -q '^resultado: desequilibrado$' <<< "$out"
test "$(campo posicion <<< "$out")" -eq 5
out=$(bash "$program2" "$fixture/estructura_extra_apertura.txt")
grep -q '^resultado: desequilibrado$' <<< "$out"
test "$(campo posicion <<< "$out")" -eq 1
out=$(bash "$program2" "$fixture/caso_estructura.txt")
grep -q '^resultado: equilibrado$' <<< "$out"
printf 'xyz\n' > "$case_dir/invalida.txt"
if bash "$program2" "$case_dir/invalida.txt" >/dev/null 2>&1; then
    printf 'pila.sh no falla con caracteres no válidos.\n' >&2
    exit 1
fi
printf 'pila\tOK\n'

# ---------------------------------------------------------------------------
# Programa 3: cola (FIFO) frente a pila (LIFO)
# ---------------------------------------------------------------------------
program3="$project/scripts/cola.sh"
out=$(bash "$program3" "$fixture/lecturas.txt")
grep -q '^cola (FIFO): lectura_a lectura_b lectura_c lectura_d$' <<< "$out"
grep -q '^pila (LIFO): lectura_d lectura_c lectura_b lectura_a$' <<< "$out"
out=$(bash "$program3" "$fixture/caso_ids.txt")
grep -q '^cola (FIFO): read_1 read_2 read_3$' <<< "$out"
grep -q '^pila (LIFO): read_3 read_2 read_1$' <<< "$out"
if bash "$program3" "$case_dir/no_existe.txt" >/dev/null 2>&1; then
    printf 'cola.sh no falla con un fichero inexistente.\n' >&2
    exit 1
fi
printf 'cola\tOK\n'

printf 'TC04_SUBMISSION_TESTS_OK\n'
