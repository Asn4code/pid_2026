#!/usr/bin/env bash
# Crea el espacio de trabajo del anexo de BC-CH11.
# Uso: practice_assets/create_workspace.sh [DESTINO]   (por defecto BC11_entrega)
set -euo pipefail
DEST="${1:-BC11_entrega}"
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CAP="$(cd "$AQUI/.." && pwd)"
if [ -e "$DEST" ]; then echo "ERROR: '$DEST' ya existe; elija otro nombre o retírelo antes." >&2; exit 1; fi
mkdir -p "$DEST/datos" "$DEST/notas" "$DEST/resultados" "$DEST/herramienta"
cp -- "$CAP/data/bc11_estructura.pdb" "$CAP/data/manifest.sha256" "$DEST/datos/"
cp -- "$CAP/verification/chapter_checks.py" "$DEST/herramienta/chapter_checks.py"
cp -- "$AQUI/comprobar_procesador.py" "$DEST/herramienta/comprobar_procesador.py"
cp -- "$AQUI/comprobar_procesador.sh" "$DEST/herramienta/check_procesador.sh"
chmod +x "$DEST/herramienta/check_procesador.sh"
cat > "$DEST/mi_procesador_pdb.py" <<'EOF'
#!/usr/bin/env python3
"""Procesador de estructuras de BC-CH11. Escriba aqui su implementacion.

Uso previsto:  python3 mi_procesador_pdb.py FICHERO.pdb

Contrato que comprueba herramienta/check_procesador.sh:
  - lee las lineas ATOM por POSICION de columna, no separando por espacios
  - cuenta solo los atomos de la proteina: HETATM no es uno de ellos
  - informa en la forma  ATOMOS:<n>  B_MEDIO:<x>  B_MAXIMO:<x>
  - emite una linea que empiece por AVISO cuando haya atomos con factor de
    temperatura por encima de 50, que es donde la densidad deja de ser fiable
  - informa de las lineas mal formadas en vez de ignorarlas en silencio
"""
import sys

def main() -> int:
    raise NotImplementedError("escriba el procesador")

if __name__ == "__main__":
    raise SystemExit(main())
EOF
printf 'apartado\tprediccion\tresultado\tcoincide\tjustificacion\n' > "$DEST/notas/respuestas.tsv"
echo "Espacio de trabajo creado en '$DEST': datos/ (estructura y manifiesto), mi_procesador_pdb.py (plantilla vacía), notas/respuestas.tsv (solo cabecera), resultados/ (vacía), herramienta/ (oráculo y comprobador)"
