#!/usr/bin/env bash
# Crea el espacio de trabajo del anexo de BC-CH12: datos con su manifiesto,
# el comprobador público y una plantilla vacía del módulo de predicción.
# Uso: practice_assets/create_workspace.sh [DESTINO]   (por defecto BC12_entrega)
set -euo pipefail
DEST="${1:-BC12_entrega}"
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CAP="$(cd "$AQUI/.." && pwd)"
if [ -e "$DEST" ]; then echo "ERROR: '$DEST' ya existe; elija otro nombre o retírelo antes." >&2; exit 1; fi
mkdir -p "$DEST/data" "$DEST/notas" "$DEST/resultados" "$DEST/verification"
cp -r -- "$CAP/data/." "$DEST/data/"
cp -- "$CAP/verification/practice_checks.py" "$CAP/verification/chapter_checks.py" "$DEST/verification/"
cp -- "$AQUI/comprobar_prediccion.py" "$DEST/verification/comprobar_prediccion.py"
cat > "$DEST/check_prediccion.sh" <<'EOF'
#!/usr/bin/env bash
# Prueba mi_prediccion.py contra su contrato. Ejecutelo cuantas veces quiera.
set -uo pipefail
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
python3 "$AQUI/verification/comprobar_prediccion.py" "${1:-$AQUI/mi_prediccion.py}"
EOF
chmod +x "$DEST/check_prediccion.sh"
cat > "$DEST/mi_prediccion.py" <<'EOF'
#!/usr/bin/env python3
"""Modulo de prediccion de BC-CH12. Escriba aqui su implementacion.

Contrato que comprueba verification/comprobar_prediccion.py:

  identidad_secuencia(a, b)
      porcentaje de posiciones identicas entre dos secuencias ya alineadas y de
      la misma longitud. Un hueco alineado con otro hueco no cuenta como
      coincidencia. Rechaza con ValueError las longitudes distintas y la
      secuencia vacia.

  zona_de_fiabilidad(identidad)
      'segura', 'penumbra' o 'medianoche' segun los umbrales de Rost del
      capitulo. Los umbrales se toman cerrados por abajo: 30.0 es zona segura y
      20.0 es penumbra.

  probabilidad_metropolis(delta_e, t)
      probabilidad de aceptacion del criterio de Metropolis. Devuelve 1.0
      cuando el movimiento no empeora la energia. Lanza ValueError cuando el
      parametro de muestreo no es estrictamente positivo.

  clashscore(choques, atomos)
      solapamientos estericos severos por cada 1000 atomos. Lanza ValueError
      con cero atomos o con choques negativos.
"""


def identidad_secuencia(a: str, b: str) -> float:
    raise NotImplementedError("escriba identidad_secuencia")


def zona_de_fiabilidad(identidad: float) -> str:
    raise NotImplementedError("escriba zona_de_fiabilidad")


def probabilidad_metropolis(delta_e: float, t: float) -> float:
    raise NotImplementedError("escriba probabilidad_metropolis")


def clashscore(choques: int, atomos: int) -> float:
    raise NotImplementedError("escriba clashscore")
EOF
printf 'par\tprediccion_identidad\tprediccion_zona\tresultado_identidad\tresultado_zona\tcoincide\tjustificacion\n' > "$DEST/notas/respuestas.tsv"
echo "Espacio de trabajo creado en '$DEST': mi_prediccion.py (plantilla vacía), data/ con los cuatro pares y su manifiesto, verification/ con el comprobador público, notas/respuestas.tsv (solo cabecera) y resultados/ (vacía)"
