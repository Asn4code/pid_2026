#!/usr/bin/env bash
# Crea el espacio de trabajo del anexo de BC-CH07.
set -euo pipefail
DEST="${1:-BC07_entrega}"
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CAP="$(cd "$AQUI/.." && pwd)"
if [ -e "$DEST" ]; then echo "ERROR: '$DEST' ya existe; elija otro nombre o retírelo antes." >&2; exit 1; fi
mkdir -p "$DEST/notas" "$DEST/resultados" "$DEST/herramienta"
cp -- "$CAP/verification/chapter_checks.py" "$DEST/herramienta/chapter_checks.py"
cp -- "$AQUI/comprobar_calidad.py" "$DEST/herramienta/comprobar_calidad.py"
cp -- "$AQUI/comprobar_calidad.sh" "$DEST/herramienta/check_calidad.sh"
chmod +x "$DEST/herramienta/check_calidad.sh"
cat > "$DEST/mi_control_calidad.py" <<'EOF'
#!/usr/bin/env python3
"""Modulo de control de calidad de BC-CH07. Escriba aqui su implementacion.

Contrato que comprueba herramienta/check_calidad.sh:

  puntuacion(caracter)            entero de la escala; rechaza con ValueError
                                  cualquier caracter por debajo del rango
                                  imprimible que usa el formato
  media_calidad(cadena)           media de las puntuaciones de la cadena
  recortar(cadena, ventana, umbral)
                                  posicion de corte por ventana deslizante: la
                                  primera ventana cuya media baja del umbral
                                  marca el final de la lectura conservada
"""

DESPLAZAMIENTO = 33


def puntuacion(caracter: str) -> int:
    raise NotImplementedError("escriba puntuacion")


def media_calidad(cadena: str) -> float:
    raise NotImplementedError("escriba media_calidad")


def recortar(cadena: str, ventana: int, umbral: float) -> int:
    raise NotImplementedError("escriba recortar")
EOF
printf 'apartado\tprediccion\tresultado\tcoincide\tjustificacion\n' > "$DEST/notas/respuestas.tsv"
echo "Espacio de trabajo creado en '$DEST': mi_control_calidad.py (plantilla vacía), notas/respuestas.tsv (solo cabecera), resultados/ (vacía), herramienta/ (oráculo y comprobador)"
