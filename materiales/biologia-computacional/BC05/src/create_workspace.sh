#!/usr/bin/env bash
# Crea el espacio de trabajo del anexo de BC-CH05.
# Uso: practice_assets/create_workspace.sh [DESTINO]   (por defecto BC05_entrega)
set -euo pipefail
DEST="${1:-BC05_entrega}"
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CAP="$(cd "$AQUI/.." && pwd)"
if [ -e "$DEST" ]; then echo "ERROR: '$DEST' ya existe; elija otro nombre o retírelo antes." >&2; exit 1; fi
mkdir -p "$DEST/datos" "$DEST/notas" "$DEST/resultados" "$DEST/herramienta"
cp -- "$CAP/data/bc05_estructura.pdb" "$CAP/data/manifest.sha256" "$DEST/datos/"
cp -- "$CAP/verification/chapter_checks.py" "$DEST/herramienta/chapter_checks.py"
cp -- "$AQUI/comprobar_geometria.py" "$DEST/herramienta/comprobar_geometria.py"
cp -- "$AQUI/comprobar_geometria.sh" "$DEST/herramienta/check_geometria.sh"
chmod +x "$DEST/herramienta/check_geometria.sh"
cat > "$DEST/mi_geometria.py" <<'EOF'
#!/usr/bin/env python3
"""Modulo de geometria estructural de BC-CH05. Escriba aqui su implementacion.

Contrato que comprueba herramienta/check_geometria.sh:

  distancia(p1, p2)              distancia euclidea entre dos puntos de tres
                                 coordenadas; debe ser simetrica
  centroide(puntos)              punto medio de una lista de puntos
  mapa_contactos(puntos, umbral) numero de pares de puntos separados por menos
                                 del umbral; subir el umbral nunca puede
                                 reducir ese numero
"""
from typing import Sequence, Tuple

Punto = Tuple[float, float, float]


def distancia(p1: Punto, p2: Punto) -> float:
    raise NotImplementedError("escriba distancia")


def centroide(puntos: Sequence[Punto]) -> Punto:
    raise NotImplementedError("escriba centroide")


def mapa_contactos(puntos: Sequence[Punto], umbral: float):
    raise NotImplementedError("escriba mapa_contactos")
EOF
printf 'apartado\tprediccion\tresultado\tcoincide\tjustificacion\n' > "$DEST/notas/respuestas.tsv"
echo "Espacio de trabajo creado en '$DEST': datos/ (estructura y manifiesto), mi_geometria.py (plantilla vacía), notas/respuestas.tsv (solo cabecera), resultados/ (vacía), herramienta/ (oráculo y comprobador)"
