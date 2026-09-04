#!/usr/bin/env bash
set -uo pipefail
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
python3 "$AQUI/comprobar_alineador.py" "${1:-$AQUI/../mi_alineador.py}"
