#!/usr/bin/env bash
# smoke_test.sh — Verifica integridad del módulo BC02
# Uso: bash src/smoke_test.sh [--report]
# Generación: tools/templates/src_smoke_test.sh

set -euo pipefail

MODULE="BC02"
PASS=0
FAIL=0
REPORT=""

test_file() {
    local path="$1"
    local desc="$2"
    if [[ -f "$path" ]]; then
        PASS=$((PASS + 1))
        REPORT="${REPORT}PASS:$desc\n"
        echo "  OK $desc"
    else
        FAIL=$((FAIL + 1))
        REPORT="${REPORT}FAIL:$desc\n"
        echo "  FAIL $desc (se esperaba $path)"
    fi
}

test_dir() {
    local path="$1"
    local desc="$2"
    if [[ -d "$path" ]]; then
        PASS=$((PASS + 1))
        REPORT="${REPORT}PASS:$desc\n"
        echo "  OK $desc"
    else
        FAIL=$((FAIL + 1))
        REPORT="${REPORT}FAIL:$desc\n"
        echo "  FAIL $desc (se esperaba $path)"
    fi
}

echo "===== Smoke test: $MODULE ====="

# Estructura
test_dir  "datos"                "Directorio datos/"
test_dir  "datos/corpus"         "Subdirectorio datos/corpus/"
test_file "datos/README.md"      "Descripción de datos"
test_file "datos/MANIFEST.sha256" "MANIFEST.sha256"
test_file "datos/SHA256SUMS"     "SHA256SUMS"
test_file "datos/mini.tsv"   "mini.tsv (caso mínimo)"
test_file "datos/caso_s02.tsv" "caso_s02.tsv (caso de error)"
test_dir  "entrega"              "Directorio entrega/"
test_file "entrega/plantilla_evidencia.md"  "Evidencia"
test_file "entrega/plantilla_pruebas.tsv"   "Pruebas"
test_file "entrega/plantilla_README.md"     "README estudiante"
test_dir  "notebooks"            "Directorio notebooks/"
test_file "notebooks/${MODULE}_colab.ipynb" "Notebook Colab"
test_file "README.md"            "README del módulo"
test_dir  "src"                  "Directorio src/"
test_file "src/smoke_test.sh"    "smoke_test.sh"
test_file "src/preparar_practica.sh" "preparar_practica.sh"
test_file "src/verificar_entrega.sh" "verificar_entrega.sh"

# Verificación de checksums (desde datos/)
if [[ -d "datos" ]]; then
    cd datos
    if [[ -f "SHA256SUMS" ]]; then
        if grep -q "^[0-9a-f]" SHA256SUMS 2>/dev/null; then
            if sha256sum -c SHA256SUMS >/dev/null 2>&1; then
                PASS=$((PASS + 1))
                echo "  OK Verificación SHA256SUMS (datos/)"
            else
                FAIL=$((FAIL + 1))
                echo "  FAIL Verificación SHA256SUMS (datos/)"
            fi
        else
            echo "  SKIP SHA256SUMS vacío"
        fi
    fi
    if [[ -f "MANIFEST.sha256" ]]; then
        if grep -q "^[0-9a-f]" MANIFEST.sha256 2>/dev/null; then
            if sha256sum -c MANIFEST.sha256 >/dev/null 2>&1; then
                PASS=$((PASS + 1))
                echo "  OK Verificación MANIFEST.sha256 (datos/)"
            else
                FAIL=$((FAIL + 1))
                echo "  FAIL Verificación MANIFEST.sha256 (datos/)"
            fi
        else
            echo "  SKIP MANIFEST.sha256 vacío"
        fi
    fi
    cd ..
fi

# Paquete
if [[ -f "paquete/${MODULE}_starter_v0.1.0.tar.gz" ]]; then
    if [[ -s "paquete/${MODULE}_starter_v0.1.0.tar.gz" ]]; then
        PASS=$((PASS + 1))
        echo "  OK Paquete starter (no vacío)"
    else
        FAIL=$((FAIL + 1))
        echo "  FAIL Paquete starter (vacío)"
    fi
else
    FAIL=$((FAIL + 1))
    echo "  FAIL Paquete starter (no existe)"
fi

echo ""
echo "Resultados: $PASS OK, $FAIL fallos"

if ((FAIL == 0)); then
    echo "${MODULE}_SMOKE_TEST_OK"
    exit 0
else
    echo "${MODULE}_SMOKE_TEST_FAIL: $FAIL fallos"
    exit 1
fi
