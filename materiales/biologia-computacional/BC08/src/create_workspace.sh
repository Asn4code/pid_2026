#!/usr/bin/env bash
set -euo pipefail
DEST="${1:-BC08_entrega}"
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CAP="$(cd "$AQUI/.." && pwd)"
if [ -e "$DEST" ]; then echo "ERROR: '$DEST' ya existe; elija otro nombre o retírelo antes." >&2; exit 1; fi
mkdir -p "$DEST/notas" "$DEST/resultados" "$DEST/herramienta"
cp -- "$CAP/verification/chapter_checks.py" "$DEST/herramienta/chapter_checks.py"
cp -- "$AQUI/comprobar_alineador.py" "$DEST/herramienta/comprobar_alineador.py"
cp -- "$AQUI/comprobar_alineador.sh" "$DEST/herramienta/check_alineador.sh"
chmod +x "$DEST/herramienta/check_alineador.sh"
cat > "$DEST/mi_alineador.py" <<'EOF'
#!/usr/bin/env python3
"""Indice y alineador de BC-CH08. Escriba aqui su implementacion.

Contrato que comprueba herramienta/check_alineador.sh:

  construir_indice(genoma, k)   diccionario k-mero -> lista de posiciones,
                                numeradas desde 1; rechaza con ValueError un
                                genoma mas corto que k o un k no positivo
  localizar(genoma, lectura, k) lista ordenada de todas las posiciones donde la
                                lectura encaja entera; lista vacia si no encaja
                                en ninguna. Use la primera semilla de k bases
                                para proponer candidatos y extienda despues
"""
from typing import Dict, List


def construir_indice(genoma: str, k: int) -> Dict[str, List[int]]:
    raise NotImplementedError("escriba construir_indice")


def localizar(genoma: str, lectura: str, k: int) -> List[int]:
    raise NotImplementedError("escriba localizar")
EOF
printf 'apartado\tprediccion\tresultado\tcoincide\tjustificacion\n' > "$DEST/notas/respuestas.tsv"
echo "Espacio de trabajo creado en '$DEST': mi_alineador.py (plantilla vacía), notas/respuestas.tsv (solo cabecera), resultados/ (vacía), herramienta/ (oráculo y comprobador)"
