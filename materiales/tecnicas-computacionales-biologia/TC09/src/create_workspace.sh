#!/usr/bin/env bash
# Crea el espacio de trabajo del anexo de TC-CH09: carpetas, oráculo,
# comprobador y plantillas vacías de la matriz y del guion de verificación.
# Uso: practice_assets/create_workspace.sh [DESTINO]   (por defecto TC09_entrega)
set -euo pipefail
DEST="${1:-TC09_entrega}"
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CAP="$(cd "$AQUI/.." && pwd)"
if [ -e "$DEST" ]; then echo "ERROR: '$DEST' ya existe; elija otro nombre o retírelo antes." >&2; exit 1; fi
mkdir -p "$DEST/notas" "$DEST/resultados" "$DEST/scripts" "$DEST/herramienta"
cp -- "$CAP/verification/chapter_results.sh" "$DEST/herramienta/chapter_results.sh"
cp -- "$AQUI/comprobar_entrega.sh" "$DEST/herramienta/check_trabajo.sh"
chmod +x "$DEST/herramienta/"*.sh
cat > "$DEST/notas/mi_matriz.tsv" <<'EOF'
# Matriz de Needleman-Wunsch para X=GAT (filas) frente a Y=GC (columnas),
# con coincidencia +1, sustitucion -1 y hueco -2. Rellenela a mano.
# Una fila por i, con los tres valores de j separados por tabulador.
i	j0	j1	j2
0			
1			
2			
3			
EOF
cat > "$DEST/scripts/verificar_puntuacion.sh" <<'EOF'
#!/usr/bin/env bash
# verificar_puntuacion.sh ALINEAMIENTO_X ALINEAMIENTO_Y - escriba aqui su implementacion.
#
# Contrato:
#   recibe  : dos cadenas de la misma longitud, con guiones donde hay huecos
#   produce : una linea "PUNTUACION:<valor>" con la suma columna a columna,
#             usando +1 por coincidencia, -1 por sustitucion y -2 por hueco
#   rechaza : dos cadenas de longitud distinta, y una columna con hueco en las
#             dos, avisando por la salida de error y terminando con estado != 0
set -euo pipefail
exit 0
EOF
chmod +x "$DEST/scripts/verificar_puntuacion.sh"
printf 'apartado\tprediccion\tresultado\tcoincide\tjustificacion\n' > "$DEST/notas/respuestas.tsv"
echo "Espacio de trabajo creado en '$DEST': notas/mi_matriz.tsv (celdas vacías), scripts/verificar_puntuacion.sh (plantilla vacía), notas/respuestas.tsv (solo cabecera), resultados/ (vacía), herramienta/ (oráculo y comprobador)"
