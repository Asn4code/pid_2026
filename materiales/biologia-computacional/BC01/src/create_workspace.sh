#!/usr/bin/env bash
# Crea el espacio de trabajo del anexo de BC-CH01: carpetas, copia de los datos
# de partida, la herramienta de contraste y una plantilla vacía del módulo.
# Uso: practice_assets/create_workspace.sh [DESTINO]   (por defecto BC01_entrega)
set -euo pipefail
DEST="${1:-BC01_entrega}"
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CAP="$(cd "$AQUI/.." && pwd)"
if [ -e "$DEST" ]; then echo "ERROR: '$DEST' ya existe; elija otro nombre o retírelo antes." >&2; exit 1; fi
mkdir -p "$DEST/datos" "$DEST/notas" "$DEST/resultados" "$DEST/herramienta"
cp -- "$CAP/data/bc01_secuencias.fasta" "$CAP/data/bc01_lecturas_crudas.txt" "$CAP/data/manifest.sha256" "$DEST/datos/"
cp -- "$CAP/verification/chapter_checks.py" "$DEST/herramienta/chapter_checks.py"
cp -- "$AQUI/comprobar_modulo.py" "$DEST/herramienta/comprobar_modulo.py"
cat > "$DEST/herramienta/check_modulo.sh" <<'EOF'
#!/usr/bin/env bash
# Prueba su módulo contra las cinco propiedades. Ejecútelo cuantas veces quiera.
set -uo pipefail
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
python3 "$AQUI/comprobar_modulo.py" "${1:-$AQUI/../mi_modulo_secuencias.py}"
EOF
chmod +x "$DEST/herramienta/check_modulo.sh"
cat > "$DEST/mi_modulo_secuencias.py" <<'EOF'
#!/usr/bin/env python3
"""Modulo de secuencias de BC-CH01. Escriba aqui su implementacion.

Contrato que comprueba herramienta/check_modulo.sh:
  validar_adn(seq) -> str            normaliza y valida, o lanza ValueError
  contenido_gc(seq) -> float         porcentaje de G y C
  complemento_reverso(seq) -> str    complementa e invierte
  transcribir(seq) -> str            cada T pasa a U
  perfil_gc(seq, ventana, paso=1) -> list[float]   ventana rodante
"""
from typing import List

ALFABETO_ADN = {'A', 'C', 'G', 'T'}
TABLA_COMPLEMENTO = {'A': 'T', 'T': 'A', 'C': 'G', 'G': 'C'}


def validar_adn(seq: str) -> str:
    raise NotImplementedError("escriba validar_adn")


def contenido_gc(seq: str) -> float:
    raise NotImplementedError("escriba contenido_gc")


def complemento_reverso(seq: str) -> str:
    raise NotImplementedError("escriba complemento_reverso")


def transcribir(seq: str) -> str:
    raise NotImplementedError("escriba transcribir")


def perfil_gc(seq: str, ventana: int, paso: int = 1) -> List[float]:
    raise NotImplementedError("escriba perfil_gc")
EOF
printf 'pregunta\tprediccion\tresultado\tcoincide\n' > "$DEST/notas/respuestas.tsv"
echo "Espacio de trabajo creado en '$DEST': datos/ (2 ficheros + manifiesto), mi_modulo_secuencias.py (plantilla vacía), notas/respuestas.tsv (solo cabecera), resultados/ (vacía), herramienta/ (oráculo y comprobador)."
