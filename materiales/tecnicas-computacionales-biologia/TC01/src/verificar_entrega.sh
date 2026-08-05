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

programs=(extremos_fasta.sh inventario.sh resumir_fichero.sh)
for program in "${programs[@]}"; do
    path="$project/scripts/$program"
    if [[ ! -f "$path" ]]; then
        printf 'Falta scripts/%s\n' "$program" >&2
        exit 1
    fi
    bash -n "$path"
done

case_dir=$(mktemp -d "${TMPDIR:-/tmp}/tc01-submission.XXXXXX")
cleanup() {
    rm -rf -- "$case_dir"
}
trap cleanup EXIT HUP INT TERM

fixture="$case_dir/corpus con espacios"
empty="$case_dir/vacio"
work="$case_dir/trabajo"
mkdir -p -- "$fixture" "$empty" "$work/resultados"
cp -a -- "$practice_dir/datos/corpus/." "$fixture/"

program1="$project/scripts/extremos_fasta.sh"
output1=$(cd "$work" && bash "$program1" "$fixture")
test "$(grep -c '^== .* ==$' <<< "$output1")" -eq 11
grep -Fq 'muestra con espacio.fasta' <<< "$output1"
if (cd "$work" && bash "$program1" "$empty") >/dev/null 2>&1; then
    printf 'extremos_fasta.sh no falla con un directorio vacío.\n' >&2
    exit 1
fi
if (cd "$work" && bash "$program1" "$case_dir/no_existe") >/dev/null 2>&1; then
    printf 'extremos_fasta.sh no falla con un directorio inexistente.\n' >&2
    exit 1
fi
printf 'extremos_fasta\tOK\n'

program2="$project/scripts/inventario.sh"
output2=$(cd "$work" && bash "$program2" "$fixture")
grep -Eq '(^|[^0-9])6([^0-9]|$)' <<< "$output2"
test "$(wc -l < "$work/resultados/file_list.txt")" -eq 21
test "$(wc -l < "$work/resultados/summary.txt")" -eq 10
LC_ALL=C sort -c "$work/resultados/file_list.txt"
grep -Fxq 'muestra con espacio.fasta' "$work/resultados/file_list.txt"
grep -Fxq 'notas campo.txt' "$work/resultados/file_list.txt"
before=$(sha256sum "$work/resultados/file_list.txt" "$work/resultados/summary.txt")
(cd "$work" && bash "$program2" "$fixture") >/dev/null
after=$(sha256sum "$work/resultados/file_list.txt" "$work/resultados/summary.txt")
test "$before" = "$after"
if (cd "$work" && bash "$program2" "$case_dir/no_existe") >/dev/null 2>&1; then
    printf 'inventario.sh no falla con un directorio inexistente.\n' >&2
    exit 1
fi
printf 'inventario\tOK\n'

program3="$project/scripts/resumir_fichero.sh"
(cd "$work" && bash "$program3" "$fixture/file_4.fasta") >"$case_dir/out19"
cmp -s "$fixture/file_4.fasta" "$case_dir/out19"
head -n 20 "$fixture/file_5.fasta" >"$case_dir/caso20.txt"
(cd "$work" && bash "$program3" "$case_dir/caso20.txt") >"$case_dir/out20"
cmp -s "$case_dir/caso20.txt" "$case_dir/out20"
{
    head -n 10 "$fixture/file_5.fasta"
    tail -n 10 "$fixture/file_5.fasta"
} >"$case_dir/expected21"
(cd "$work" && bash "$program3" "$fixture/file_5.fasta") \
    >"$case_dir/out21" 2>"$case_dir/err21"
tail -n 20 "$case_dir/out21" >"$case_dir/content21"
cmp -s "$case_dir/expected21" "$case_dir/content21"
grep -Eqi 'aviso|21|lineas|líneas' "$case_dir/out21" "$case_dir/err21"
if (cd "$work" && bash "$program3") >/dev/null 2>&1; then
    printf 'resumir_fichero.sh no falla sin argumentos.\n' >&2
    exit 1
fi
if (cd "$work" && bash "$program3" "$case_dir/no_existe") >/dev/null 2>&1; then
    printf 'resumir_fichero.sh no falla con un fichero inexistente.\n' >&2
    exit 1
fi
if (cd "$work" && bash "$program3" "$fixture/file_4.fasta" extra) \
    >/dev/null 2>&1; then
    printf 'resumir_fichero.sh no falla con argumentos de más.\n' >&2
    exit 1
fi
printf 'resumir_fichero\tOK\n'
printf 'TC01_SUBMISSION_TESTS_OK\n'

