#!/usr/bin/env bash
# Comprueba mi_pila.sh y mi_cola.sh contra el comportamiento que define su
# contrato. No imprime las respuestas del anexo: dice qué cumple y qué no.
# Uso: herramienta/check_estructuras.sh [DIRECTORIO_ENTREGA]
set -uo pipefail
W="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
cd "$W" || { echo "no se puede entrar en $W" >&2; exit 2; }
fallos=0; ko() { echo "FALLO: $*"; fallos=$((fallos+1)); }; ok() { echo "OK: $*"; }
for s in mi_pila mi_cola; do
  [ -f "scripts/$s.sh" ] || { ko "scripts/$s.sh no existe"; continue; }
  bash -n "scripts/$s.sh" 2>/dev/null || ko "scripts/$s.sh no pasa bash -n"
done
[ "$fallos" -eq 0 ] || { echo "ESTRUCTURAS_INCOMPLETO: $fallos"; exit 1; }

corre() { printf '%s\n' "$2" | bash "scripts/$1.sh" 2>/dev/null; }

# pila: orden inverso de salida
sal=$(corre mi_pila "$(printf 'push A\npush B\npush C\npop\npop\npop')")
esperado=$(printf 'PUSH:A\nPUSH:B\nPUSH:C\nPOP:C\nPOP:B\nPOP:A')
[ "$sal" = "$esperado" ] && ok "la pila devuelve los elementos en orden inverso al de entrada" || ko "la pila no respeta el orden LIFO; se esperaban tres POP en orden inverso y llegó: $(printf '%s' "$sal" | tr '\n' ' ')"
# pila: consulta y vacío
sal=$(corre mi_pila "$(printf 'esta_vacia\npush X\npeek\npeek\npop\nesta_vacia\npop')")
esperado=$(printf 'VACIA:SI\nPUSH:X\nPEEK:X\nPEEK:X\nPOP:X\nVACIA:SI\nPOP:VACIA')
[ "$sal" = "$esperado" ] && ok "la pila consulta sin sacar y avisa cuando está vacía" || ko "la pila falla en peek, esta_vacia o en el subdesbordamiento; llegó: $(printf '%s' "$sal" | tr '\n' ' ')"
# cola: orden de llegada
sal=$(corre mi_cola "$(printf 'enqueue A\nenqueue B\nenqueue C\ndequeue\ndequeue\ndequeue')")
esperado=$(printf 'ENQUEUE:A\nENQUEUE:B\nENQUEUE:C\nDEQUEUE:A\nDEQUEUE:B\nDEQUEUE:C')
[ "$sal" = "$esperado" ] && ok "la cola devuelve los elementos en su orden de llegada" || ko "la cola no respeta el orden FIFO; llegó: $(printf '%s' "$sal" | tr '\n' ' ')"
# cola: consulta y vacío
sal=$(corre mi_cola "$(printf 'esta_vacia\nenqueue X\nenqueue Y\nfrente\ndequeue\nfrente\ndequeue\ndequeue')")
esperado=$(printf 'VACIA:SI\nENQUEUE:X\nENQUEUE:Y\nFRENTE:X\nDEQUEUE:X\nFRENTE:Y\nDEQUEUE:Y\nDEQUEUE:VACIA')
[ "$sal" = "$esperado" ] && ok "la cola consulta el frente sin sacarlo y avisa cuando está vacía" || ko "la cola falla en frente, esta_vacia o en el subdesbordamiento; llegó: $(printf '%s' "$sal" | tr '\n' ' ')"
# la pila del alumno valida el anidamiento por clases
valida() {
  local cadena="$1" ops="" c abre cierre
  for ((i = 0; i < ${#cadena}; i++)); do
    c="${cadena:i:1}"
    case "$c" in
      '('|'[') ops+="push $c"$'\n' ;;
      ')'|']') ops+="pop"$'\n' ;;
    esac
  done
  printf '%s' "$ops" | bash scripts/mi_pila.sh 2>/dev/null | grep -c '^POP:VACIA' || true
}
[ "$(valida '(()')" = "0" ] && [ "$(valida '())')" = "1" ] && ok "la pila del alumno sirve para detectar cierres sin apertura" || ko "la pila no permite detectar un cierre sin apertura: revise POP sobre pila vacía"
if [ "$fallos" -eq 0 ]; then echo "ESTRUCTURAS_OK: la pila y la cola cumplen su contrato"; exit 0; fi
echo "ESTRUCTURAS_INCOMPLETO: $fallos comprobaciones sin superar"; exit 1
