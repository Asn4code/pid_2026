# Biología Computacional — BC05

| Campo | Valor |
|---|---|
| Versión | 0.1.0 |
| Responsable | Álvaro Serrano Navarro |
| Fecha | 2026-08-04 |
| Asignatura | Biología Computacional |
| Módulo | BC05 |
| Sesión(es) | S5 |
| Tipo de sesión | T |
| Resultados de guía | por definir |
| Evidencia | por definir |
| Diapositivas | por definir |
| Uso de IA | por definir |

---

## Pregunta guía

por definir

## Objetivo

Al finalizar el módulo, cada estudiante deberá ser capaz de:

- [ ] Describir el concepto principal del módulo.
- [ ] Aplicar el método o herramienta en un caso de práctica.
- [ ] Interpretar el resultado y explicar sus límites.
- [ ] Justificar una decisión técnica o biológica.

## Preguntas de recuperación y predicción

Antes de la sesión, responde individualmente:

1. ¿Qué sabes ya sobre por definir?
2. ¿Qué esperas obtener de esta práctica?

> **Predicción sin IA:** Escribe tu respuesta antes de consultar herramientas de inteligencia artificial.

## Dependencias

| Herramienta | Versión | Notas |
|---|---|---|
| Bash | 4+ | Shell estándar de Linux |
| Python | 3.9+ | Solo si se requiere para la práctica |
| Otras | — | Listar aquí |

## Entorno de trabajo

### Local (Linux)

```bash
# Descomprimir el starter package
tar -xzf paquete/BC05_starter_v0.1.0.tar.gz
cd BC05_starter
```

### Google Colab

Abre el cuaderno `notebooks/BC05_colab.ipynb` en Google Colab. El cuaderno descarga automáticamente el paquete starter.

## Caso mínimo

El archivo `datos/mini.<ext>` contiene un caso pequeño para probar el flujo completo sin consumir tiempo de cómputo.

```bash
# Verificar integridad de los datos
cd datos
sha256sum -c SHA256SUMS
sha256sum -c MANIFEST.sha256
```

## Práctica completa

### Paso 1: Exploración inicial

Ejecuta el caso mínimo y describe lo que observas.

### Paso 2: Ejecución del análisis

Sigue los pasos indicados en las instrucciones de clase.

### Paso 3: Modificación y auditoría

Cambia al menos un parámetro o dato y observa el efecto.

### Paso 4: Interpretación

Relaciona la salida con la pregunta biológica o computacional.

## Validación

Ejecuta los scripts de verificación:

```bash
# Verificar entorno y estructura
bash src/smoke_test.sh

# Verificar estructura de entrega
bash src/verificar_entrega.sh
```

La salida debe mostrar `OK` en todos los tests.

## README del estudiante

Crea tu propia explicación en `entrega/README.md` siguiendo la plantilla:

```bash
cp entrega/plantilla_README.md entrega/README.md
# Edita el archivo con tus respuestas
```

## Paridad local / nube

| Aspecto | Local | Colab |
|---|---|---|
| Datos | `datos/` (mismo checksum) | Descargados automáticamente |
| Scripts | `src/` | Copiados en celdas |
| Salida | Mismo formato | Mismo formato |
| Entrega | `entrega/` | `entrega/` |

## Checklist de verificación

Antes de entregar, verifica que cumples los 9 criterios de "módulo listo":

- [ ] Capítulo narrativo terminado y PDF accesible generado.
- [ ] Correspondencia con guía, resultados y sesiones comprobada.
- [ ] Diapositivas seleccionadas como apoyo, no como único contenido.
- [ ] Predicción, ejemplo, práctica y fallo/contraste probados.
- [ ] Ejecución local/nube equivalente o contingencia institucional/precalculada.
- [ ] Tarea, rúbrica o evidencia formativa configurada.
- [ ] Vista de estudiante, enlaces, referencias y accesibilidad revisados.
- [ ] Versión, responsable y fecha registrados.
- [ ] Datos verificados con checksums (`sha256sum -c`).

---

*Documento generado automáticamente por `generate_module_skeleton.sh`.*
