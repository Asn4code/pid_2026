#!/usr/bin/env bash
set -uo pipefail
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
python3 "$AQUI/comprobar_modulo.py" "${1:-$AQUI/../mi_modulo_expresion.py}"
