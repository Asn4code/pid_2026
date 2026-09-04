#!/usr/bin/env bash
# Crea el espacio de trabajo del anexo de BC-CH09: datos, comprobador público
# y una plantilla vacía del módulo de anclaje.
# Uso: practice_assets/create_workspace.sh [DESTINO]   (por defecto BC09_entrega)
set -euo pipefail
DEST="${1:-BC09_entrega}"
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CAP="$(cd "$AQUI/.." && pwd)"
if [ -e "$DEST" ]; then echo "ERROR: '$DEST' ya existe; elija otro nombre o retírelo antes." >&2; exit 1; fi
mkdir -p "$DEST/data" "$DEST/notas" "$DEST/resultados" "$DEST/verification"
cp -r -- "$CAP/data/." "$DEST/data/"
cp -- "$CAP/verification/practice_checks.py" "$CAP/verification/practice_public_checker.py" "$DEST/verification/"
cp -- "$CAP/verification/chapter_checks.py" "$DEST/verification/" 2>/dev/null || true
cp -- "$CAP/verification/fixtures.py" "$DEST/verification/" 2>/dev/null || true
cp -- "$CAP/verification/distances.py" "$DEST/verification/" 2>/dev/null || true
cp -- "$AQUI/comprobar_anclaje.py" "$DEST/verification/comprobar_anclaje.py"
cat > "$DEST/check_anclaje.sh" <<'EOF'
#!/usr/bin/env bash
# Prueba mi_anclaje.py contra su contrato. Ejecutelo cuantas veces quiera.
set -uo pipefail
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
python3 "$AQUI/verification/comprobar_anclaje.py" "${1:-$AQUI/mi_anclaje.py}"
EOF
chmod +x "$DEST/check_anclaje.sh"
cat > "$DEST/mi_anclaje.py" <<'EOF'
#!/usr/bin/env python3
"""Modulo de anclaje de BC-CH09. Escriba aqui su implementacion.

Contrato que comprueba practice_assets/check_delivery.sh:

  p_distance(a, b)     proporcion de posiciones que difieren entre dos
                       secuencias ya alineadas y de la misma longitud
  jc69(p)              distancia corregida; lanza ValueError cuando p queda
                       fuera del dominio de la correccion
  primera_fusion(d13, d23)
                       distancia del cluster recien formado al tercer taxon,
                       con la regla de actualizacion ponderada del capitulo
"""


def p_distance(a: str, b: str) -> float:
    raise NotImplementedError("escriba p_distance")


def jc69(p: float) -> float:
    raise NotImplementedError("escriba jc69")


def primera_fusion(d13: float, d23: float) -> float:
    raise NotImplementedError("escriba primera_fusion")
EOF
printf 'variante\torden_de_fusion\taltura_raiz\tque_cambio\n' > "$DEST/notas/variantes.tsv"
echo "Espacio de trabajo creado en '$DEST': mi_anclaje.py (plantilla vacía), data/ con su manifiesto, verification/ con el comprobador público, notas/variantes.tsv (solo cabecera), resultados/ (vacía)"
