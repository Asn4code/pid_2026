# Técnicas Computacionales en Biología — TC08: Bayes, cadenas de Markov y modelos ocultos

| Campo | Valor |
|---|---|
| Versión | v4.0 |
| Edición | 2 |
| Responsable | Álvaro Serrano Navarro |
| Fecha | 2026-09-04 |
| Asignatura | Técnicas Computacionales en Biología |
| Módulo | TC08 |

---

## Pregunta del tema

Dos regiones del genoma tienen exactamente las mismas proporciones de A, C, G y T. Una es una isla CpG y la otra no. ¿Qué hay que medir, si las frecuencias no bastan, y cómo se decide cuando la propiedad que interesa no está escrita en la secuencia?

## Producto final

Una matriz de transición estimada por usted a partir de una secuencia, validada fila a fila, y una decodificación de Viterbi cuyo camino óptimo se contrasta con lo que diría mirar cada posición por separado.

## Qué hay en esta carpeta

- `datos/` · los datos de partida con su manifiesto de sumas.
- `src/` · el generador del espacio de trabajo y el verificador de entrega.
- `paquete/TC08_practica_v4.0.tar.gz` · todo lo anterior empaquetado, que es
  la forma cómoda de descargarlo de una vez.

## Cómo empezar

    tar -xzf TC08_practica_v4.0.tar.gz
    cd TC-CH08
    ./practice_assets/create_workspace.sh entrega
    cd entrega

El generador crea la plantilla de su módulo **sin implementar** y la tabla de
respuestas con solo su cabecera. Antes de ejecutar nada, escriba lo que espera
obtener: el contraste entre predicción y resultado es lo que se evalúa.

## Cómo comprobar que ha terminado

    ./practice_assets/check_entrega.sh entrega

No pone nota. Rechaza la entrega vacía y el espacio de trabajo recién generado.
