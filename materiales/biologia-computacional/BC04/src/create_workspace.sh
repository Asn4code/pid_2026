#!/usr/bin/env bash
# Crea el espacio de trabajo del anexo de BC-CH04: oráculo, comprobador y una
# plantilla vacía del módulo de expresión.
# Uso: practice_assets/create_workspace.sh [DESTINO]   (por defecto BC04_entrega)
set -euo pipefail
DEST="${1:-BC04_entrega}"
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CAP="$(cd "$AQUI/.." && pwd)"
if [ -e "$DEST" ]; then echo "ERROR: '$DEST' ya existe; elija otro nombre o retírelo antes." >&2; exit 1; fi
mkdir -p "$DEST/notas" "$DEST/resultados" "$DEST/herramienta"
cp -- "$CAP/verification/chapter_checks.py" "$DEST/herramienta/chapter_checks.py"
cp -- "$AQUI/comprobar_modulo.py" "$DEST/herramienta/comprobar_modulo.py"
cp -- "$AQUI/comprobar_modulo.sh" "$DEST/herramienta/check_modulo.sh"
chmod +x "$DEST/herramienta/check_modulo.sh"
cat > "$DEST/mi_modulo_expresion.py" <<'EOF'
#!/usr/bin/env python3
"""Modulo de expresion de BC-CH04. Escriba aqui su implementacion.

Contrato que comprueba herramienta/check_modulo.sh:

  buscar_orfs(adn, minimo)     busca marcos abiertos canonicos en los seis
                               marcos, descartando los mas cortos que el
                               umbral dado en nucleotidos; devuelve una lista
  traducir(adn)                traduce de tres en tres desde el primer
                               nucleotido, con la tabla estandar, incluyendo
                               el asterisco de la parada
  normalizar_tpm(conteos, longitudes)
                               devuelve una lista de valores normalizados cuya
                               suma es exactamente un millon
"""
from typing import List

TABLA_CODONES = {}   # complete con la tabla del capitulo


def buscar_orfs(adn: str, minimo: int) -> List[str]:
    raise NotImplementedError("escriba buscar_orfs")


def traducir(adn: str) -> str:
    raise NotImplementedError("escriba traducir")


def normalizar_tpm(conteos, longitudes) -> List[float]:
    raise NotImplementedError("escriba normalizar_tpm")
EOF
printf 'apartado\tprediccion\tresultado\tcoincide\tjustificacion\n' > "$DEST/notas/respuestas.tsv"
echo "Espacio de trabajo creado en '$DEST': mi_modulo_expresion.py (plantilla vacía), notas/respuestas.tsv (solo cabecera), resultados/ (vacía), herramienta/ (oráculo y comprobador)"
