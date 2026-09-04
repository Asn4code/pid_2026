# Técnicas Computacionales en Biología — TC09: Alineamiento, similitud y búsqueda en bases de datos

| Campo | Valor |
|---|---|
| Versión | v4.0 |
| Edición | 2 |
| Responsable | Álvaro Serrano Navarro |
| Fecha | 2026-09-04 |
| Asignatura | Técnicas Computacionales en Biología |
| Módulo | TC09 |

---

## Pregunta del tema

Dos secuencias de organismos distintos se parecen. ¿Cuánto de ese parecido significa algo y cuánto era esperable por azar, dado el tamaño de la base de datos en la que las buscó?

## Producto final

Una matriz de programación dinámica rellenada a mano y verificada contra el oráculo, un guion propio que recalcula la puntuación de un alineamiento columna a columna, y tres valores esperados que muestran qué cambia el tamaño de la base de datos y qué no.

## Qué hay en esta carpeta

- `datos/` · los datos de partida con su manifiesto de sumas.
- `src/` · el generador del espacio de trabajo y el verificador de entrega.
- `paquete/TC09_practica_v4.0.tar.gz` · todo lo anterior empaquetado, que es
  la forma cómoda de descargarlo de una vez.

## Cómo empezar

    tar -xzf TC09_practica_v4.0.tar.gz
    cd TC-CH09
    ./practice_assets/create_workspace.sh entrega
    cd entrega

El generador crea la plantilla de su módulo **sin implementar** y la tabla de
respuestas con solo su cabecera. Antes de ejecutar nada, escriba lo que espera
obtener: el contraste entre predicción y resultado es lo que se evalúa.

## Cómo comprobar que ha terminado

    ./practice_assets/check_entrega.sh entrega

No pone nota. Rechaza la entrega vacía y el espacio de trabajo recién generado.
