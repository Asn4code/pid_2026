#!/usr/bin/env bash
# preparar_practica.sh — Prepara el entorno de trabajo del estudiante para el módulo BC07
# Uso: bash src/preparar_practica.sh
# Generación: tools/templates/src_preparar_practica.sh

set -euo pipefail

MODULE="BC07"
MODULE_LOWER=$(echo "$MODULE" | tr '[:upper:]' '[:lower:]')

echo "===== Preparación del entorno: $MODULE ====="
echo ""

# 1. Verificar datos
if [[ ! -d "datos" ]]; then
    echo "❌ Directorio datos/ no encontrado"
    exit 1
fi

echo "✅ Verificando datos..."
cd datos
if [[ -f "SHA256SUMS" ]]; then
    if sha256sum -c SHA256SUMS > /dev/null 2>&1; then
        echo "  ✅ SHA256SUMS verificado"
    else
        echo "  ❌ SHA256SUMS falló — descarga de nuevo o verifica"
        exit 1
    fi
fi
if [[ -f "MANIFEST.sha256" ]]; then
    if sha256sum -c MANIFEST.sha256 > /dev/null 2>&1; then
        echo "  ✅ MANIFEST.sha256 verificado"
    else
        echo "  ❌ MANIFEST.sha256 falló — descarga de nuevo o verifica"
        exit 1
    fi
fi

# 2. Crear directorio de trabajo
WORKDIR="${MODULE_LOWER}_work"
mkdir -p "$WORKDIR"
echo ""
echo "📁 Directorio de trabajo creado: $WORKDIR/"

# 3. Copiar datos al directorio de trabajo
cp datos/mini.* "$WORKDIR/" 2>/dev/null || cp datos/* "$WORKDIR/"
cp -r datos/corpus "$WORKDIR/" 2>/dev/null || true

# 4. Copiar scripts de verificación
cp src/verificar_entrega.sh "$WORKDIR/"
echo "  ✅ Scripts de verificación copiados"

# 5. Instrucciones
echo ""
echo "===== Listo para trabajar ====="
echo "Carpeta de trabajo: $(pwd)/$WORKDIR/"
echo "Ejecuta: cd $WORKDIR && bash verificar_entrega.sh"
echo ""
echo "Recuerda:"
echo "  - Trabaja sobre COPIAS, no los datos originales"
echo "  - Guarda tu evidencia en $WORKDIR/entrega/"
echo "  - Verifica con verificar_entrega.sh antes de entregar"

echo ""
echo "${MODULE}_PREPARADO_OK"
