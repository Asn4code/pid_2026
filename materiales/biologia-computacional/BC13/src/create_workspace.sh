#!/usr/bin/env bash
# Crea el espacio de trabajo del anexo de BC-CH13: los cuatro modelos con su
# manifiesto, el comprobador público y una plantilla vacía del módulo.
# Uso: practice_assets/create_workspace.sh [DESTINO]   (por defecto BC13_entrega)
set -euo pipefail
DEST="${1:-BC13_entrega}"
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CAP="$(cd "$AQUI/.." && pwd)"
if [ -e "$DEST" ]; then echo "ERROR: '$DEST' ya existe; elija otro nombre o retírelo antes." >&2; exit 1; fi
mkdir -p "$DEST/data" "$DEST/notas" "$DEST/resultados" "$DEST/verification"
cp -r -- "$CAP/data/." "$DEST/data/"
cp -- "$CAP/verification/practice_checks.py" "$CAP/verification/chapter_checks.py" "$DEST/verification/"
cp -- "$AQUI/comprobar_auditoria.py" "$DEST/verification/comprobar_auditoria.py"
cat > "$DEST/check_auditoria.sh" <<'EOF'
#!/usr/bin/env bash
# Prueba mi_auditoria.py contra su contrato. Ejecutelo cuantas veces quiera.
set -uo pipefail
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
python3 "$AQUI/verification/comprobar_auditoria.py" "${1:-$AQUI/mi_auditoria.py}"
EOF
chmod +x "$DEST/check_auditoria.sh"
cat > "$DEST/mi_auditoria.py" <<'EOF'
#!/usr/bin/env python3
"""Modulo de auditoria de BC-CH13. Escriba aqui su implementacion.

Contrato que comprueba verification/comprobar_auditoria.py:

  banda_plddt(score)
      'muy_alta', 'alta', 'baja' o 'muy_baja' segun las bandas del capitulo.
      Las fronteras van cerradas por abajo: 90.0 es muy alta, 70.0 es alta y
      50.0 es baja. Lanza ValueError fuera del intervalo [0, 100].

  plddt_medio(scores)
      confianza media del modelo. Rechaza la lista vacia y cualquier valor
      fuera de [0, 100].

  dictamen_pae(matriz)
      devuelve la pareja (media, dictamen) de una submatriz PAE entre dos
      dominios. El dictamen es 'rigida' por debajo de 5 angstrom, 'flexible'
      por encima de 15 e 'intermedia' entre ambos, con 5 e 15 incluidos en el
      caso intermedio. Rechaza la matriz vacia y la no rectangular.

  desigualdad_triangular(d12, d23, d13)
      True si las tres distancias pueden realizarse en el espacio euclideo.
      El caso degenerado, con los tres puntos alineados, si es realizable.
      Lanza ValueError con distancias negativas.
"""


def banda_plddt(score: float) -> str:
    raise NotImplementedError("escriba banda_plddt")


def plddt_medio(scores: list) -> float:
    raise NotImplementedError("escriba plddt_medio")


def dictamen_pae(matriz: list) -> tuple:
    raise NotImplementedError("escriba dictamen_pae")


def desigualdad_triangular(d12: float, d23: float, d13: float) -> bool:
    raise NotImplementedError("escriba desigualdad_triangular")
EOF
printf 'modelo\tprediccion_banda_media\tprediccion_pae\tresultado_plddt_medio\tresultado_pae\tuso_admisible\tjustificacion\n' > "$DEST/notas/dictamen.tsv"
echo "Espacio de trabajo creado en '$DEST': mi_auditoria.py (plantilla vacía), data/ con los cuatro modelos y su manifiesto, verification/ con el comprobador público, notas/dictamen.tsv (solo cabecera) y resultados/ (vacía)"
