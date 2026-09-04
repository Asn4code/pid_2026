# Técnicas Computacionales en Biología — TC02: Bash, automatización y procesamiento de texto

| Campo | Valor |
|---|---|
| Versión | v4.0 |
| Edición | 2 |
| Responsable | Álvaro Serrano Navarro |
| Fecha | 2026-09-04 |
| Asignatura | Técnicas Computacionales en Biología |
| Módulo | TC02 |

---

## Pregunta del tema

Ha ejecutado a mano la misma orden sobre veinte ficheros y mañana llegan veinte más. ¿Cómo se convierte esa secuencia de órdenes en un procedimiento que otra persona pueda ejecutar, leer y corregir?

## Producto final

Un script propio, con sus comprobaciones y su registro, que recorre un corpus de ficheros biológicos y produce una tabla de resultados reproducible.

## Qué hay en esta carpeta

- `datos/` · los datos de partida con su manifiesto de sumas.
- `src/` · el generador del espacio de trabajo y el verificador de entrega.
- `paquete/TC02_practica_v4.0.tar.gz` · todo lo anterior empaquetado, que es
  la forma cómoda de descargarlo de una vez.

## Cómo empezar

    tar -xzf TC02_practica_v4.0.tar.gz
    cd TC-CH02
    ./practice_assets/create_workspace.sh entrega
    cd entrega

El generador crea la plantilla de su módulo **sin implementar** y la tabla de
respuestas con solo su cabecera. Antes de ejecutar nada, escriba lo que espera
obtener: el contraste entre predicción y resultado es lo que se evalúa.

## Cómo comprobar que ha terminado

    ./practice_assets/check_entrega.sh entrega

No pone nota. Rechaza la entrega vacía y el espacio de trabajo recién generado.
