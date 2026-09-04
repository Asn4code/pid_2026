#!/usr/bin/env bash
# Crea el espacio de trabajo del anexo de BC-CH10: datos con su manifiesto,
# el comprobador público y una plantilla vacía del módulo de diseño.
# Uso: practice_assets/create_workspace.sh [DESTINO]   (por defecto BC10_entrega)
set -euo pipefail
DEST="${1:-BC10_entrega}"
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CAP="$(cd "$AQUI/.." && pwd)"
if [ -e "$DEST" ]; then echo "ERROR: '$DEST' ya existe; elija otro nombre o retírelo antes." >&2; exit 1; fi
mkdir -p "$DEST/data" "$DEST/notas" "$DEST/resultados" "$DEST/verification"
cp -r -- "$CAP/data/." "$DEST/data/"
cp -- "$CAP/verification/practice_checks.py" "$CAP/verification/chapter_checks.py" "$DEST/verification/"
cp -- "$AQUI/comprobar_diseno.py" "$DEST/verification/comprobar_diseno.py"
cat > "$DEST/check_diseno.sh" <<'EOF'
#!/usr/bin/env bash
# Prueba mi_diseno.py contra su contrato. Ejecutelo cuantas veces quiera.
set -uo pipefail
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
python3 "$AQUI/verification/comprobar_diseno.py" "${1:-$AQUI/mi_diseno.py}"
EOF
chmod +x "$DEST/check_diseno.sh"
cat > "$DEST/mi_diseno.py" <<'EOF'
#!/usr/bin/env python3
"""Modulo de diseno de BC-CH10. Escriba aqui su implementacion.

Contrato que comprueba verification/comprobar_diseno.py:

  contenido_gc(seq)
      porcentaje de guanina y citosina de la secuencia, entre 0.0 y 100.0.
      Rechaza la secuencia vacia con ValueError.

  temperatura_fusion(seq)
      temperatura de fusion en grados Celsius con la formula empirica basada
      en composicion del capitulo. Lanza ValueError cuando la secuencia tiene
      menos de 10 nucleotidos, porque ahi la formula deja de estar calibrada.

  dianas_restriccion(seq, motivo)
      posiciones en base 1 donde aparece el motivo, en orden creciente. Las
      apariciones solapadas cuentan todas. Si el motivo no aparece, lista vacia.
"""


def contenido_gc(seq: str) -> float:
    raise NotImplementedError("escriba contenido_gc")


def temperatura_fusion(seq: str) -> float:
    raise NotImplementedError("escriba temperatura_fusion")


def dianas_restriccion(seq: str, motivo: str) -> list:
    raise NotImplementedError("escriba dianas_restriccion")
EOF
printf 'cebador\tprediccion_gc\tprediccion_tm\tresultado_gc\tresultado_tm\tcoincide\tjustificacion\n' > "$DEST/notas/respuestas.tsv"
echo "Espacio de trabajo creado en '$DEST': mi_diseno.py (plantilla vacía), data/ con los cinco cebadores y su manifiesto, verification/ con el comprobador público, notas/respuestas.tsv (solo cabecera) y resultados/ (vacía)"
