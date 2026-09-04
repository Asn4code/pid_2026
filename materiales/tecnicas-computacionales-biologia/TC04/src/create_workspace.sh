#!/usr/bin/env bash
# Crea el espacio de trabajo del anexo de TC-CH04: carpetas, oráculo del
# capítulo y dos plantillas vacías, una por estructura.
# Uso: practice_assets/create_workspace.sh [DESTINO]   (por defecto TC04_entrega)
set -euo pipefail
DEST="${1:-TC04_entrega}"
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CAP="$(cd "$AQUI/.." && pwd)"
if [ -e "$DEST" ]; then echo "ERROR: '$DEST' ya existe; elija otro nombre o retírelo antes." >&2; exit 1; fi
mkdir -p "$DEST/notas" "$DEST/resultados" "$DEST/scripts" "$DEST/herramienta"
cp -- "$CAP/verification/chapter_results.sh" "$DEST/herramienta/chapter_results.sh"
cp -- "$AQUI/comprobar_estructuras.sh" "$DEST/herramienta/check_estructuras.sh"
chmod +x "$DEST/herramienta/"*.sh
cat > "$DEST/scripts/mi_pila.sh" <<'EOF'
#!/usr/bin/env bash
# mi_pila.sh - pila LIFO sobre un array de Bash. Escriba aqui su implementacion.
#
# Lee una operacion por linea de la entrada estandar y escribe una linea por
# operacion en la salida estandar:
#   push V       ->  PUSH:V
#   pop          ->  POP:V      o  POP:VACIA si no queda nada
#   peek         ->  PEEK:V     o  PEEK:VACIA
#   esta_vacia   ->  VACIA:SI   o  VACIA:NO
set -euo pipefail
exit 0
EOF
cat > "$DEST/scripts/mi_cola.sh" <<'EOF'
#!/usr/bin/env bash
# mi_cola.sh - cola FIFO sobre un array de Bash. Escriba aqui su implementacion.
#
# Lee una operacion por linea de la entrada estandar y escribe una linea por
# operacion en la salida estandar:
#   enqueue V    ->  ENQUEUE:V
#   dequeue      ->  DEQUEUE:V  o  DEQUEUE:VACIA si no queda nada
#   frente       ->  FRENTE:V   o  FRENTE:VACIA
#   esta_vacia   ->  VACIA:SI   o  VACIA:NO
set -euo pipefail
exit 0
EOF
chmod +x "$DEST/scripts/"*.sh
printf 'apartado\tprediccion\tresultado\tjustificacion\n' > "$DEST/notas/respuestas.tsv"
echo "Espacio de trabajo creado en '$DEST': scripts/ (dos plantillas vacías), notas/respuestas.tsv (solo cabecera), resultados/ (vacía), herramienta/ (oráculo y comprobador)"
