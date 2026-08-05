#!/usr/bin/env bash
# verificar_entrega.sh DIRECTORIO_SCRIPTS
# Valida en caja negra los tres scripts de la práctica TC05 contra el oráculo
# del capítulo, sin mirar su código. Espera encontrar bst.sh, codones.sh y
# bfs.sh en el directorio indicado.
set -euo pipefail

if (($# != 1)); then
    printf 'Uso: %s DIRECTORIO_SCRIPTS\n' "$(basename "$0")" >&2
    exit 2
fi
dir=$1
for s in bst.sh codones.sh bfs.sh; do
    if [[ ! -f "$dir/$s" ]]; then
        printf 'Falta el script: %s/%s\n' "$dir" "$s" >&2
        exit 1
    fi
done

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
practice_dir=$(cd -- "$script_dir/.." && pwd -P)
datos="$practice_dir/datos"

fallos=0
comprobar() {
    local descripcion=$1 esperado=$2 obtenido=$3
    if [[ "$obtenido" == "$esperado" ]]; then
        printf '  OK   %s\n' "$descripcion"
    else
        printf '  FALLO %s\n        esperado: [%s]\n        obtenido: [%s]\n' \
            "$descripcion" "$esperado" "$obtenido"
        fallos=$((fallos + 1))
    fi
}

# 1) bst.sh: recorrido in-order del árbol balanceado del capítulo.
obt=$(bash "$dir/bst.sh" "$datos/caso_bst.txt" | grep '^in-order:' | sed 's/^in-order: //')
comprobar "bst in-order {5,3,8,1,4,7,9}" "1 3 4 5 7 8 9" "$obt"

# 2) bst.sh: degeneración con entrada ordenada -> altura 6.
obt=$(bash "$dir/bst.sh" "$datos/caso_bst_ordenado.txt" | grep '^altura:' | sed 's/^altura: //')
comprobar "bst altura con entrada ordenada" "6" "$obt"

# 3) codones.sh: traducción del ARNm del capítulo.
obt=$(bash "$dir/codones.sh" "$datos/caso_arnm.fasta" | grep '^proteina:' | sed 's/^proteina: //')
comprobar "codones traduccion AUGAAUCUGCCU" "Met Asn Leu Pro" "$obt"

# 4) codones.sh: número de aminoácidos distintos.
obt=$(bash "$dir/codones.sh" "$datos/caso_arnm.fasta" | grep '^aminoacidos_distintos:' | sed 's/^aminoacidos_distintos: //')
comprobar "codones aminoacidos distintos" "4" "$obt"

# 5) bfs.sh: distancias en la red del capítulo desde A.
obt=$(bash "$dir/bfs.sh" "$datos/caso_red.txt" A)
comprobar "bfs distancias desde A" "A0 B1 C1 D2 E3" "$obt"

# 6) Frontera: un fichero inexistente debe rechazarse con estado != 0.
if bash "$dir/bfs.sh" "$datos/no_existe.txt" A >/dev/null 2>&1; then
    printf '  FALLO bfs debería rechazar un fichero inexistente\n'
    fallos=$((fallos + 1))
else
    printf '  OK   bfs rechaza fichero inexistente\n'
fi

if ((fallos == 0)); then
    printf 'TC05_SUBMISSION_TESTS_OK\n'
    exit 0
fi
printf '%d comprobación(es) fallida(s).\n' "$fallos" >&2
exit 1
