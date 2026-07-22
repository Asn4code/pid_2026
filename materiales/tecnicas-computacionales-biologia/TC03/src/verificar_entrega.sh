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

programs=(buscar.sh motivo.sh escalado.sh)
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
cp -- "$practice_dir/datos/caso_busqueda.txt" "$fixture/"
cp -- "$practice_dir/datos/caso_motivo.fasta" "$fixture/"
printf '%s\n' 9 4 7 1 3 > "$case_dir/desordenada.txt"

# Extrae el número de comparaciones de una línea "clave: estado (N comparaciones)".
comparaciones() {
    sed -n -E "s/^$1: .*\\(([0-9]+) comparaciones\\).*/\\1/p"
}

# ---------------------------------------------------------------------------
# Programa 1: búsqueda lineal frente a binaria
# ---------------------------------------------------------------------------
program1="$project/scripts/buscar.sh"

out=$(bash "$program1" "$fixture/caso_busqueda.txt" 33)
grep -q 'lineal: posicion 8' <<< "$out"
grep -q 'binaria: posicion 8' <<< "$out"
test "$(comparaciones lineal <<< "$out")" -eq 8
test "$(comparaciones binaria <<< "$out")" -eq 1

out=$(bash "$program1" "$fixture/enteros_31.txt" 100)
grep -q 'lineal: posicion 31' <<< "$out"
test "$(comparaciones lineal <<< "$out")" -eq 31
test "$(comparaciones binaria <<< "$out")" -eq 5

out=$(bash "$program1" "$fixture/caso_busqueda.txt" 34)
grep -q 'lineal: ausente' <<< "$out"
grep -q 'binaria: ausente' <<< "$out"
test "$(comparaciones lineal <<< "$out")" -eq 15
test "$(comparaciones binaria <<< "$out")" -eq 4

if bash "$program1" "$case_dir/desordenada.txt" 7 >/dev/null 2>&1; then
    printf 'buscar.sh no falla con una lista desordenada.\n' >&2
    exit 1
fi
if bash "$program1" "$case_dir/no_existe.txt" 7 >/dev/null 2>&1; then
    printf 'buscar.sh no falla con un fichero inexistente.\n' >&2
    exit 1
fi
if bash "$program1" "$fixture/caso_busqueda.txt" AB >/dev/null 2>&1; then
    printf 'buscar.sh no falla con un objetivo no entero.\n' >&2
    exit 1
fi
printf 'buscar\tOK\n'

# ---------------------------------------------------------------------------
# Programa 2: búsqueda de motivo por fuerza bruta
# ---------------------------------------------------------------------------
program2="$project/scripts/motivo.sh"
ocurrencias() { sed -n -E 's/^ocurrencias: ([0-9]+).*/\1/p'; }
comps_motivo() { sed -n -E 's/^comparaciones: ([0-9]+).*/\1/p'; }

out=$(bash "$program2" "$fixture/adn_3.fasta" ATG)
test "$(ocurrencias <<< "$out")" -eq 5
test "$(comps_motivo <<< "$out")" -eq 23

out=$(bash "$program2" "$fixture/adn_4.fasta" ATG)
test "$(ocurrencias <<< "$out")" -eq 0

out=$(bash "$program2" "$fixture/adn_4.fasta" CG)
test "$(ocurrencias <<< "$out")" -eq 8

if bash "$program2" "$fixture/adn_1.fasta" atgx >/dev/null 2>&1; then
    printf 'motivo.sh no falla con un motivo no válido.\n' >&2
    exit 1
fi
if bash "$program2" "$case_dir/no_existe.fasta" ATG >/dev/null 2>&1; then
    printf 'motivo.sh no falla con un fichero inexistente.\n' >&2
    exit 1
fi
printf 'motivo\tOK\n'

# ---------------------------------------------------------------------------
# Programa 3: crecimiento empírico lineal frente a cuadrático
# ---------------------------------------------------------------------------
program3="$project/scripts/escalado.sh"
work="$case_dir/trabajo"
mkdir -p -- "$work/datos" "$work/resultados"
cp -- "$practice_dir/datos/tamanos.txt" "$work/datos/"

(cd "$work" && bash "$program3") >/dev/null
tabla="$work/resultados/escalado.tsv"
test -f "$tabla"
grep -q $'^n\tlineal\tcuadratica$' "$tabla"
grep -q $'^2\t2\t1$' "$tabla"
grep -q $'^4\t4\t6$' "$tabla"
grep -q $'^8\t8\t28$' "$tabla"
grep -q $'^16\t16\t120$' "$tabla"
grep -q $'^32\t32\t496$' "$tabla"

before=$(sha256sum "$tabla")
(cd "$work" && bash "$program3") >/dev/null
after=$(sha256sum "$tabla")
test "$before" = "$after"

printf '%s\n' 4 0 8 > "$work/datos/tamanos.txt"
if (cd "$work" && bash "$program3") >/dev/null 2>&1; then
    printf 'escalado.sh no falla con un tamaño no válido.\n' >&2
    exit 1
fi
printf 'escalado\tOK\n'

printf 'TC03_SUBMISSION_TESTS_OK\n'
