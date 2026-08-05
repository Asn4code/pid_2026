#!/usr/bin/env bash
# generate_module_skeleton.sh — Genera la estructura de directorios para un módulo docente
# Uso: bash tools/generate_module_skeleton.sh <MODULE_CODE> <ASIGNATURA_TYPE>
# Ejemplo: bash tools/generate_module_skeleton.sh BC01 biologia
#          bash tools/generate_module_skeleton.sh TC06 tecnicas

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/templates"
BASE_DIR="$SCRIPT_DIR/../materiales"

if [[ $# -ne 2 ]]; then
    echo "Uso: bash $0 <MODULE_CODE> <ASIGNATURA_TYPE>"
    echo "  MODULE_CODE:   ej. BC01, TC06"
    echo "  ASIGNATURA_TYPE: biologia | tecnicas"
    exit 1
fi

MODULE="$1"
ATYPE="$2"

if ! echo "$MODULE" | grep -qE '^[A-Z]{2}[0-9]{2}$'; then
    echo "Error: MODULE_CODE debe tener formato XX## (ej. BC01, TC06)"
    exit 1
fi

if [[ "$ATYPE" != "biologia" && "$ATYPE" != "tecnicas" ]]; then
    echo "Error: ASIGNATURA_TYPE debe ser 'biologia' o 'tecnicas'"
    exit 1
fi

case "$ATYPE" in
    biologia)
        ASIGNATURA="biologia-computacional"
        ASIGNATURA_DISPLAY="Biología Computacional"
        DATA_EXT="fasta"
        ;;
    tecnicas)
        ASIGNATURA="tecnicas-computacionales-biologia"
        ASIGNATURA_DISPLAY="Técnicas Computacionales en Biología"
        DATA_EXT="txt"
        ;;
esac

BASE_PATH="$BASE_DIR/$ASIGNATURA/$MODULE"

# Determinar sesiones
NUM="${MODULE//[!0-9]/}"
PREFIX="${MODULE//[0-9]/}"
case "$PREFIX" in
    BC)
        SESSIONS="S$((10#$NUM))"
        SESSION_RANGE="S$((10#$NUM))"
        ;;
    TC)
        START=$((10#$NUM * 3 - 2))
        END=$((10#$NUM * 3))
        SESSIONS="S${START}-S${END}"
        SESSION_RANGE="S${START}-S${END}"
        ;;
esac

echo "===== Generando esqueleto: $MODULE ($ASIGNATURA_DISPLAY) ====="
echo "  Ruta: $BASE_PATH"
echo "  Sesiones: $SESSIONS"
echo ""

# Crear directorios
mkdir -p "$BASE_PATH/datos/corpus"
mkdir -p "$BASE_PATH/entrega"
mkdir -p "$BASE_PATH/notebooks"
mkdir -p "$BASE_PATH/paquete"
mkdir -p "$BASE_PATH/src"

# Función de sustitución de placeholders
substitute_placeholders() {
    local file="$1"
    local output="$2"
    sed \
        -e "s|{{MODULE}}|$MODULE|g" \
        -e "s|{{ASIGNATURA}}|$ASIGNATURA|g" \
        -e "s|{{ASIGNATURA_DISPLAY}}|$ASIGNATURA_DISPLAY|g" \
        -e "s|{{VERSION}}|0.1.0|g" \
        -e "s|{{FECHA}}|$(date +%Y-%m-%d)|g" \
        -e "s|{{SESION}}|$SESSIONS|g" \
        -e "s|{{SESION_RANGE}}|$SESSION_RANGE|g" \
        -e "s|{{TIPO_SESION}}|T|g" \
        -e "s|{{RESULTADOS}}|por definir|g" \
        -e "s|{{EVIDENCIA}}|por definir|g" \
        -e "s|{{DIAPOSITIVAS}}|por definir|g" \
        -e "s|{{IA}}|por definir|g" \
        -e "s|{{PREGUNTA}}|por definir|g" \
        -e "s|{{TEMA}}|por definir|g" \
        "$file" > "$output"
}

# Copiar y sustituir plantillas
echo "  Copiando plantillas..."

# README
substitute_placeholders \
    "$TEMPLATE_DIR/README_TEMPLATE.md" \
    "$BASE_PATH/README.md"

# Notebook
substitute_placeholders \
    "$TEMPLATE_DIR/notebook_TEMPLATE.ipynb" \
    "$BASE_PATH/notebooks/${MODULE}_colab.ipynb"

# Scripts src (eliminar prefijo src_ del nombre de plantilla)
substitute_placeholders \
    "$TEMPLATE_DIR/src_smoke_test.sh" \
    "$BASE_PATH/src/smoke_test.sh"
chmod +x "$BASE_PATH/src/smoke_test.sh"

substitute_placeholders \
    "$TEMPLATE_DIR/src_preparar_practica.sh" \
    "$BASE_PATH/src/preparar_practica.sh"
chmod +x "$BASE_PATH/src/preparar_practica.sh"

substitute_placeholders \
    "$TEMPLATE_DIR/src_verificar_entrega.sh" \
    "$BASE_PATH/src/verificar_entrega.sh"
chmod +x "$BASE_PATH/src/verificar_entrega.sh"

# Plantillas de entrega (eliminar prefijo plantilla_ del nombre de plantilla)
substitute_placeholders \
    "$TEMPLATE_DIR/entrega_template_evidencia.md" \
    "$BASE_PATH/entrega/plantilla_evidencia.md"

substitute_placeholders \
    "$TEMPLATE_DIR/entrega_template_README.md" \
    "$BASE_PATH/entrega/plantilla_README.md"

# Copiar TSV sin sustitución (no tiene placeholders)
cp "$TEMPLATE_DIR/entrega_template_pruebas.tsv" "$BASE_PATH/entrega/plantilla_pruebas.tsv"

# Archivos de datos placeholder
echo "  Creando datos placeholder..."
cat > "$BASE_PATH/datos/README.md" << DATAREADME

# Datos de $MODULE

Contenido: Datos sintéticos para la práctica del módulo $MODULE.
Licencia: CC0-1.0 (por confirmar)
Autor: Álvaro Serrano Navarro (docente)

Para verificar integridad:
  cd datos && sha256sum -c SHA256SUMS
DATAREADME
cat > "$BASE_PATH/datos/README.md" << DATAREADME2
# Datos de $MODULE

Contenido: Datos sintéticos para la práctica del módulo $MODULE.
Licencia: CC0-1.0 (por confirmar)
Autor: Álvaro Serrano Navarro (docente)

Para verificar integridad:
  cd datos && sha256sum -c SHA256SUMS
DATAREADME2

echo "# placeholder" > "$BASE_PATH/datos/mini.${DATA_EXT}"
echo "# placeholder" > "$BASE_PATH/datos/caso_s01.txt"

# SHA256SUMS vacío (se llenará con datos reales)
echo "# SHA256SUMS — se generará con los datos reales" > "$BASE_PATH/datos/SHA256SUMS"
echo "# MANIFEST.sha256 — se generará con los datos reales" > "$BASE_PATH/datos/MANIFEST.sha256"

# Paquete placeholder (archivo vacío)
touch "$BASE_PATH/paquete/${MODULE}_starter_v0.1.0.tar.gz"
echo "# SHA256SUMS del paquete — se generará al finalizar" > "$BASE_PATH/paquete/SHA256SUMS"

# Listar archivos creados
echo ""
echo "  Estructura creada:"
find "$BASE_PATH" -type f | sort | while read -r f; do
    rel="${f#/home/aserrano/Documents/pid/}"
    size=$(wc -c < "$f")
    echo "     $rel ($size bytes)"
done

echo ""
echo "  ===== $MODULE generado correctamente ====="
echo "  Ruta: $BASE_PATH"
echo "  Próximo paso: Rellenar datos reales, README específico y notebook."
