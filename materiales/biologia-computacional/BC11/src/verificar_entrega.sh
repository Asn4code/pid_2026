#!/usr/bin/env bash
# verificar_entrega.sh — Verifica la estructura de entrega para el módulo BC11
# Uso: bash src/verificar_entrega.sh [ruta_a_entrega]
# Generación: tools/templates/src_verificar_entrega.sh

set -euo pipefail

MODULE="BC11"
PASS=0
FAIL=0

TARGET="${1:-.}"

test_file() {
    local path="$1"
    local desc="$2"
    local full_path="$TARGET/$path"
    if [[ -f "$full_path" ]]; then
        ((PASS++))
        echo "  ✅ $desc: OK ($full_path)"
    else
        ((FAIL++))
        echo "  ❌ $desc: FALTANTE (se esperaba $full_path)"
    fi
}

echo "===== Verificación de entrega: $MODULE ====="
echo "Directorio a verificar: $(realpath "$TARGET")"
echo ""

# Estructura principal
test_file "README.md" "README del estudiante"
test_file "plantilla_evidencia.md" "Evidencia completada (plantilla)"
test_file "plantilla_pruebas.tsv" "Pruebas de ejecución"

# Scripts de verificación (si se ejecuta desde la carpeta del módulo)
if [[ -f "src/verificar_entrega.sh" ]]; then
    [[ -f "src/smoke_test.sh" ]] && { ((PASS++)); echo "  ✅ smoke_test.sh: presente"; } || { ((FAIL++)); echo "  ❌ smoke_test.sh: faltante"; }
    [[ -f "src/preparar_practica.sh" ]] && { ((PASS++)); echo "  ✅ preparar_practica.sh: presente"; } || { ((FAIL++)); echo "  ❌ preparar_practica.sh: faltante"; }
fi

# Archivos de datos
if [[ -f "$TARGET/datos/mini.*" ]]; then
    ((PASS++))
    echo "  ✅ Datos mínimos: presentes"
else
    echo "  ⚠️  Datos mínimos: no encontrados (se asume que se usaron los proporcionados)"
fi

echo ""
echo "Resultados: $PASS OK, $FAIL errores"

if ((FAIL == 0)); then
    echo "${MODULE}_SUBMISSION_TESTS_OK"
    echo "Estado: ESTRUCTURA COMPLETA ✅"
    exit 0
else
    echo "${MODULE}_SUBMISSION_FAIL: $FAIL errores"
    echo "Estado: ESTRUCTURA INCOMPLETA ❌"
    exit 1
fi
