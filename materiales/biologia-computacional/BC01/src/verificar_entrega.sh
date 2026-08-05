#!/usr/bin/env bash
# verificar_entrega.sh — Verifica la estructura de entrega de BC01
# Uso: bash src/verificar_entrega.sh

set -euo pipefail

PASS=0
FAIL=0

test_file() {
    local path="$1"
    local desc="$2"
    if [[ -f "$path" ]]; then
        PASS=$((PASS + 1))
        echo "  OK $desc"
    else
        FAIL=$((FAIL + 1))
        echo "  FAIL $desc (se esperaba $path)"
    fi
}

echo "===== Verificación de entrega: BC01 ====="

# Verifica que la estructura de entrega existe
test_file "entrega/plantilla_evidencia.md"  "Plantilla evidencia"
test_file "entrega/plantilla_pruebas.tsv"   "Plantilla pruebas"
test_file "entrega/plantilla_README.md"     "Plantilla README estudiante"

# Verifica datos verificados
if [[ -f "datos/SHA256SUMS" ]]; then
    PASS=$((PASS + 1))
    echo "  OK SHA256SUMS presente"
else
    FAIL=$((FAIL + 1))
    echo "  FAIL SHA256SUMS faltante"
fi

# Verifica notebook
test_file "notebooks/BC01_colab.ipynb" "Notebook Colab"

# Verifica que el estudiante copió plantilla
if [[ -f "entrega/README.md" ]]; then
    lines=$(wc -l < "entrega/README.md")
    if ((lines > 3)); then
        PASS=$((PASS + 1))
        echo "  OK README estudiante ($lines líneas)"
    else
        FAIL=$((FAIL + 1))
        echo "  FAIL README estudiante vacío ($lines líneas)"
    fi
else
    echo "  ⚠️  README del estudiante no copiado (usa: cp entrega/plantilla_README.md entrega/README.md)"
fi

echo ""
echo "Resultados: $PASS OK, $FAIL fallos"

if ((FAIL == 0)); then
    echo "BC01_SUBMISSION_TESTS_OK"
    exit 0
else
    echo "BC01_SUBMISSION_FAIL: $FAIL fallos"
    exit 1
fi
