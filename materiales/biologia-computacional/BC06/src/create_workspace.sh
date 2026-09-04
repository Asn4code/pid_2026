#!/usr/bin/env bash
# Crea el espacio de trabajo del anexo de BC-CH06.
# Uso: practice_assets/create_workspace.sh [DESTINO]   (por defecto BC06_entrega)
set -euo pipefail
DEST="${1:-BC06_entrega}"
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CAP="$(cd "$AQUI/.." && pwd)"
if [ -e "$DEST" ]; then echo "ERROR: '$DEST' ya existe; elija otro nombre o retírelo antes." >&2; exit 1; fi
mkdir -p "$DEST/notas" "$DEST/resultados" "$DEST/herramienta"
cp -- "$CAP/verification/chapter_checks.py" "$DEST/herramienta/chapter_checks.py"
cp -- "$AQUI/comprobar_calculadora.py" "$DEST/herramienta/comprobar_calculadora.py"
cp -- "$AQUI/comprobar_calculadora.sh" "$DEST/herramienta/check_calculadora.sh"
chmod +x "$DEST/herramienta/check_calculadora.sh"
cat > "$DEST/mi_calculadora.py" <<'EOF'
#!/usr/bin/env python3
"""Calculadora de dimensionamiento de BC-CH06. Escriba aqui su implementacion.

Contrato que comprueba herramienta/check_calculadora.sh:

  cobertura(lecturas, longitud, genoma)
        profundidad media que producen esas lecturas; rechaza con ValueError
        cualquier parametro nulo o negativo, que no tiene sentido fisico
  lecturas_necesarias(objetivo, longitud, genoma)
        numero entero de lecturas que hace falta para alcanzar el objetivo,
        sin quedarse corto y sin pasarse en mas de una unidad de cobertura
  fraccion_sin_cubrir(cobertura)
        fraccion del genoma que el modelo de Poisson deja sin cubrir
"""


def cobertura(lecturas: int, longitud: int, genoma: int) -> float:
    raise NotImplementedError("escriba cobertura")


def lecturas_necesarias(objetivo: float, longitud: int, genoma: int) -> int:
    raise NotImplementedError("escriba lecturas_necesarias")


def fraccion_sin_cubrir(cobertura_media: float) -> float:
    raise NotImplementedError("escriba fraccion_sin_cubrir")
EOF
printf 'apartado\tprediccion\tresultado\tcoincide\tjustificacion\n' > "$DEST/notas/respuestas.tsv"
echo "Espacio de trabajo creado en '$DEST': mi_calculadora.py (plantilla vacía), notas/respuestas.tsv (solo cabecera), resultados/ (vacía), herramienta/ (oráculo y comprobador)"
