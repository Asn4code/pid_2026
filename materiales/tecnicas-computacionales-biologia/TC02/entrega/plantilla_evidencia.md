# Evidencia individual TC02

## Identificación y entorno

- Código de estudiante:
- Fecha:
- Versión de la práctica: 0.1.0
- Vía: A (Linux local) / B (Google Colab)
- Salida de `uname -s`, `bash --version`, `sed --version` y `awk --version`:

## Datos

- Versión del corpus: 0.1.0
- Resultado de `sha256sum -c MANIFEST.sha256`:

## Programa 1: transcripción con sed

- Orden de ejecución:
- Número de sustituciones T→U en `caso.fasta`:
- Comprobación de que las cabeceras no se han modificado:
- Diferencia entre `s/T/U/` y `s/T/U/g` sobre `TTACGT`:

## Programa 2: longitudes con awk

- Orden de ejecución:
- Longitud de cada registro de `adn_3.fasta` (multilínea):
- Por qué un enfoque por línea daría un resultado incorrecto:

## Programa 3: contenido GC con awk

- Orden de ejecución:
- GC de cada registro de un fichero del corpus:
- Cómo se calcula el porcentaje sin alterar la secuencia:

## Interpretación y límites

- Cuándo usar `grep`, cuándo `sed` y cuándo `awk`:
- Un riesgo de `sed -i` y cómo lo evitas:
- Un dialecto de regex que difiere entre las tres herramientas:

## Autoría e IA

- Confirmo que los scripts, las pruebas y la evidencia son individuales: sí / no
- Uso de IA: ninguno / uso declarado
- Herramienta, consulta, fragmento afectado y verificación, si procede:

[completar o escribir «no procede»]
