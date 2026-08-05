# Biología Computacional — BC01: Introducción, entorno y reproducibilidad

| Campo | Valor |
|---|---|
| Versión | 0.1.0 |
| Responsable | Álvaro Serrano Navarro |
| Fecha | 2026-08-03 |
| Asignatura | Biología Computacional |
| Módulo | BC01 |
| Sesión(es) | S01 |
| Tipo de sesión | T |
| Resultados de guía | K5, H7, C3, C7 |
| Evidencia | Diagnóstico de entorno, manifiesto reproducible |
| Diapositivas | `temas_biologia_computacional/20250909_intro.pptx` |
| Uso de IA | A (núcleo conceptual), B (después de verificación) |

---

## Pregunta guía

¿Qué necesita otra persona para repetir exactamente un análisis bioinformático?

## Objetivo

Al finalizar el módulo, cada estudiante deberá ser capaz de:

- [ ] Describir el flujo mínimo de un análisis bioinformático:
  pregunta → datos → entorno → ejecución → evidencia
- [ ] Usar los comandos UNIX esenciales para navegar y explorar datos
- [ ] Verificar la integridad de los datos con checksum SHA-256
- [ ] Diagnosticar errores comunes de entorno (PATH, versión, archivo faltante)

## Preguntas de recuperación y predicción

Antes de la sesión, responde individualmente:

1. ¿Qué comandos UNIX usas habitualmente para ver qué archivos hay en un directorio?
2. Si quieres reproducir un análisis que hiciste hace un mes, ¿qué información necesitas conservar?

> **Predicción sin IA:** Escribe tu respuesta antes de consultar herramientas de IA.

## Dependencias

| Herramienta | Versión | Notas |
|---|---|---|
| Bash | 4+ | Shell estándar de Linux |
| sha256sum | — | Herramienta estándar de coreutils |
| wc | — | Cuenta líneas, palabras, bytes |
| grep | — | Búsqueda de patrones |
| find | — | Búsqueda de archivos |
| Python | 3.9+ | Solo si se usa el notebook de Colab |

## Entorno de trabajo

### Local (Linux)

```bash
# 1. Descomprimir el paquete starter
tar -xzf paquete/BC01_starter_v0.1.0.tar.gz

# 2. Preparar el entorno de trabajo
cd BC01_starter
bash src/preparar_practica.sh

# 3. Verificar integridad de datos
cd datos && sha256sum -c SHA256SUMS && sha256sum -c MANIFEST.sha256 && cd ..

# 4. Ejecutar la práctica
# (ver pasos abajo)

# 5. Verificar entrega
bash src/verificar_entrega.sh
```

### Google Colab

Abre el cuaderno `notebooks/BC01_colab.ipynb` en
[Google Colab](https://colab.research.google.com/). El cuaderno descarga
automáticamente el paquete starter y ejecuta los mismos pasos.

## Caso mínimo

El archivo `datos/mini.tsv` contiene una tabla con 8 filas de comandos
UNIX esenciales usados en bioinformática. Cada fila incluye:

- `comando`: el comando a ejecutar
- `descripción`: qué hace
- `resultado esperado`: salida esperada
- `error común`: fallo frecuente que los estudiantes cometen

Para verlo:
```bash
cat datos/mini.tsv | column -t -s$'\t'
```

## Práctica completa

### Paso 1: Exploración del entorno

1. Abre una terminal (o usa el notebook de Colab).
2. Navega al directorio del módulo descrito arriba.
3. Ejecuta `bash src/smoke_test.sh` y verifica que todos los tests pasan.

### Paso 2: Verificación de datos

```bash
cd datos
echo "Verificando SHA256SUMS..."
sha256sum -c SHA256SUMS
echo "Verificando MANIFEST.sha256..."
sha256sum -c MANIFEST.sha256
```

Anota el resultado de cada verificación.

### Paso 3: Análisis del caso de error

Ejecuta los comandos con los errores intencionados de `caso_s01.tsv`:

```bash
cat datos/caso_s01.tsv
# Para cada fila: intenta ejecutar, anota el error
# Luego explica: ¿por qué falla y cómo corregirlo?
```

### Paso 4: Creación del manifiesto de entorno

Genera un manifiesto reproducible:

```bash
echo "### Manifiesto de entorno — BC01" > manifiesto.txt
echo "Fecha: $(date -u +%Y-%m-%dT%H:%M:%S)" >> manifiesto.txt
echo "Sistema: $(uname -a)" >> manifiesto.txt
echo "Shell: $BASH_VERSION" >> manifiesto.txt
echo "Checksum mini.tsv:" >> manifiesto.txt
sha256sum datos/mini.tsv >> manifiesto.txt
echo "Checksum caso_s01.tsv:" >> manifiesto.txt
sha256sum datos/caso_s01.tsv >> manifiesto.txt
cat manifiesto.txt
```

### Paso 5: Interpretación

Responde en `entrega/plantilla_evidencia.md`:

- ¿Por qué es importante verificar checksums?
- ¿Qué información del manifiesto permite que otra persona repita tu análisis?
- ¿Qué pasaba cuando los datos tienen un archivo corrupto o incompleto?

## Validación

```bash
# Verificar entorno y estructura
bash src/smoke_test.sh

# Verificar estructura de entrega
bash src/verificar_entrega.sh
```

La salida debe mostrar `BC01_SMOKE_TEST_OK` y `BC01_SUBMISSION_TESTS_OK`.

## README del estudiante

```bash
cp entrega/plantilla_README.md entrega/README.md
# Edita el archivo con tus respuestas
```

## Paridad local / nube

| Aspecto | Local | Colab |
|---|---|---|
| Datos | `datos/` (mismo checksum) | Descargados automáticamente |
| Scripts | `src/` | Copiados en celdas |
| Salida | Mismo formato (bash output) | Mismo formato (print/celdas) |
| Entrega | `entrega/` | `entrega/` |
| Manifiesto | Generado con bash | Generado con python+os |

## Checklist de verificación

Antes de entregar:

- [ ] `smoke_test.sh` pasa con 0 fallos
- [ ] `sha256sum -c SHA256SUMS` → todos OK
- [ ] `sha256sum -c MANIFEST.sha256` → todos OK
- [ ] `verificar_entrega.sh` → `BC01_SUBMISSION_TESTS_OK`
- [ ] `entrega/plantilla_evidencia.md` completada
- [ ] `entrega/README.md` con explicación personal
- [ ] Manifiesto de entorno generado con checksums
- [ ] Se respondió a las 3 preguntas de interpretación
- [ ] Se declaró uso de IA (si aplica)

---

*Documento generado con `infraestructura/generate_module_skeleton.sh` y completado.*
