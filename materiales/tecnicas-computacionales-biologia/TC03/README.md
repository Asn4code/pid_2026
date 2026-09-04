# Técnicas Computacionales en Biología — TC03: Algoritmos, complejidad y estrategias de resolución

| Campo | Valor |
|---|---|
| Versión | v4.0 |
| Edición | 2 |
| Responsable | Álvaro Serrano Navarro |
| Fecha | 2026-09-04 |
| Asignatura | Técnicas Computacionales en Biología |
| Módulo | TC03 |

---

## Pregunta del tema

Un asistente automático escribe en segundos un procedimiento que compara cada lectura de secuenciación con cada posición del genoma. ¿Cómo se decide, antes de lanzarlo, si terminará esta tarde o dentro de nueve años?

## Producto final

Una auditoría razonada de tres afirmaciones de coste erróneas, con la medición propia del escalado al duplicar la entrada y la comparación entre una recursión desbocada y su versión con tabla.

## Qué hay en esta carpeta

- `datos/` · los datos de partida con su manifiesto de sumas.
- `src/` · el generador del espacio de trabajo y el verificador de entrega.
- `paquete/TC03_practica_v4.0.tar.gz` · todo lo anterior empaquetado, que es
  la forma cómoda de descargarlo de una vez.

## Cómo empezar

    tar -xzf TC03_practica_v4.0.tar.gz
    cd TC-CH03
    ./practice_assets/create_workspace.sh entrega
    cd entrega

El generador crea la plantilla de su módulo **sin implementar** y la tabla de
respuestas con solo su cabecera. Antes de ejecutar nada, escriba lo que espera
obtener: el contraste entre predicción y resultado es lo que se evalúa.

## Cómo comprobar que ha terminado

    ./practice_assets/check_entrega.sh entrega

No pone nota. Rechaza la entrega vacía y el espacio de trabajo recién generado.
