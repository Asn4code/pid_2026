#!/usr/bin/env bash
set -uo pipefail
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
python3 "$AQUI/comprobar_calidad.py" "${1:-$AQUI/../mi_control_calidad.py}"
