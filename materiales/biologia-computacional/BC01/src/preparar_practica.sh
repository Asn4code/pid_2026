#!/usr/bin/env bash
# preparar_practica.sh — Prepara el entorno de trabajo para BC01

set -euo pipefail

MODULE="BC01"

echo "===== Preparación del entorno: BC01 ====="
echo ""

if [[ ! -d "datos" ]]; then
    echo "❌ Directorio datos/ no encontrado"
    exit 1
fi

echo "✅ Verificando datos..."
cd datos
if [[ -f "SHA256SUMS" ]]; then
    if sha256sum -c SHA256SUMS >/dev/null 2>&1; then
        echo "  ✅ SHA256SUMS verificado"
    else
        echo "  ❌ SHA256SUMS falló — redescarga el paquete starter"
        exit 1
    fi
fi
if [[ -f "MANIFEST.sha256" ]]; then
    if sha256sum -c MANIFEST.sha256 >/dev/null 2>&1; then
        echo "  ✅ MANIFEST.sha256 verificado"
    else
        echo "  ❌ MANIFEST.sha256 falló — redescarga el paquete starter"
        exit 1
    fi
fi
cd ..

WORKDIR="BC01_work"
mkdir -p "$WORKDIR"
echo ""
echo "📁 Directorio de trabajo creado: $WORKDIR/"

echo ""
echo "===== Listo para trabajar ====="
echo "Carpeta: $(pwd)/$WORKDIR/"
echo "Recuerda:"
echo "  - Trabaja sobre COPIAS, no los datos originales"
echo "  - Tu evidencia va en $WORKDIR/entrega/"
echo "  - Ejecuta: bash src/verificar_entrega.sh"
echo ""
echo "BC01_PREPARADO_OK"
