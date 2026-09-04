#!/usr/bin/env bash
# Crea el espacio de trabajo del anexo de BC-CH02: carpetas, oráculo,
# comprobador y una plantilla vacía de la clase Proteina.
# Uso: practice_assets/create_workspace.sh [DESTINO]   (por defecto BC02_entrega)
set -euo pipefail
DEST="${1:-BC02_entrega}"
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CAP="$(cd "$AQUI/.." && pwd)"
if [ -e "$DEST" ]; then echo "ERROR: '$DEST' ya existe; elija otro nombre o retírelo antes." >&2; exit 1; fi
mkdir -p "$DEST/notas" "$DEST/resultados" "$DEST/herramienta"
cp -- "$CAP/verification/chapter_checks.py" "$DEST/herramienta/chapter_checks.py"
cp -- "$AQUI/comprobar_clase.py" "$DEST/herramienta/comprobar_clase.py"
cp -- "$AQUI/comprobar_clase.sh" "$DEST/herramienta/check_clase.sh"
chmod +x "$DEST/herramienta/check_clase.sh"
cat > "$DEST/mi_proteina.py" <<'EOF'
#!/usr/bin/env python3
"""Clase Proteina de BC-CH02. Escriba aqui su implementacion.

Contrato que comprueba herramienta/check_clase.sh:

  Proteina(secuencia)        normaliza espacios y mayusculas; guarda el
                             resultado en el atributo .secuencia y lanza
                             ValueError si hay algun residuo no canonico
  .masa()                    masa media en dalton: suma de masas de residuo
                             mas UNA sola agua terminal
  .composicion()             diccionario residuo -> numero de apariciones
  .hidropatia_media()        media de la escala de Kyte y Doolittle
  .perfil_hidropatia(v)      lista de ventanas de longitud v, cada una con su
                             media; con n residuos salen n - v + 1 ventanas
"""

MASAS_RESIDUO = {}   # complete con la tabla del capitulo
HIDROPATIA = {}      # complete con la escala del capitulo
AGUA = 18.015


class Proteina:
    def __init__(self, secuencia: str):
        raise NotImplementedError("escriba el constructor y su guarda")
EOF
printf 'apartado\tprediccion\tresultado\tcoincide\tjustificacion\n' > "$DEST/notas/respuestas.tsv"
echo "Espacio de trabajo creado en '$DEST': mi_proteina.py (plantilla vacía), notas/respuestas.tsv (solo cabecera), resultados/ (vacía), herramienta/ (oráculo y comprobador)"
