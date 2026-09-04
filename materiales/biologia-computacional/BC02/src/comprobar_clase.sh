#!/usr/bin/env bash
# Envoltorio: ejecuta el comprobador de la clase Proteina del alumnado.
set -uo pipefail
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
python3 "$AQUI/comprobar_clase.py" "${1:-$AQUI/../mi_proteina.py}"
