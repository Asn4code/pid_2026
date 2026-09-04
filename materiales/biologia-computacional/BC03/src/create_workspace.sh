#!/usr/bin/env bash
# Crea el espacio de trabajo del anexo de BC-CH03: datos, oráculo, comprobador
# y una plantilla vacía del procesador de variantes.
# Uso: practice_assets/create_workspace.sh [DESTINO]   (por defecto BC03_entrega)
set -euo pipefail
DEST="${1:-BC03_entrega}"
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CAP="$(cd "$AQUI/.." && pwd)"
if [ -e "$DEST" ]; then echo "ERROR: '$DEST' ya existe; elija otro nombre o retírelo antes." >&2; exit 1; fi
mkdir -p "$DEST/datos" "$DEST/notas" "$DEST/resultados" "$DEST/herramienta"
cp -- "$CAP/data/bc03_variantes.vcf" "$CAP/data/manifest.sha256" "$DEST/datos/"
cp -- "$CAP/verification/chapter_checks.py" "$DEST/herramienta/chapter_checks.py"
cp -- "$AQUI/comprobar_procesador.py" "$DEST/herramienta/comprobar_procesador.py"
cp -- "$AQUI/comprobar_procesador.sh" "$DEST/herramienta/check_procesador.sh"
chmod +x "$DEST/herramienta/check_procesador.sh"
cat > "$DEST/mi_procesador_variantes.py" <<'EOF'
#!/usr/bin/env python3
"""Procesador de variantes de BC-CH03. Escriba aqui su implementacion.

Uso previsto:  python3 mi_procesador_variantes.py FICHERO.vcf

Contrato que comprueba herramienta/check_procesador.sh:
  - lee un fichero en formato de variantes, saltando las lineas de cabecera
  - convierte la posicion, que viene en base 1, al indice en base 0 que usaria
    para acceder a la secuencia, sin producir indices negativos
  - clasifica cada variante como transicion o transversion
  - imprime el recuento en la forma  TI:<n> TV:<n> RATIO:<x>
  - emite una linea que empiece por AVISO cuando el cociente se aparte del
    intervalo esperado, que en secuenciacion de genoma completo va de 1,8 a 2,2
"""
import sys

def main() -> int:
    raise NotImplementedError("escriba el procesador")

if __name__ == "__main__":
    raise SystemExit(main())
EOF
printf 'apartado\tprediccion\tresultado\tcoincide\tjustificacion\n' > "$DEST/notas/respuestas.tsv"
echo "Espacio de trabajo creado en '$DEST': datos/ (fichero de variantes y manifiesto), mi_procesador_variantes.py (plantilla vacía), notas/respuestas.tsv (solo cabecera), resultados/ (vacía), herramienta/ (oráculo y comprobador)"
