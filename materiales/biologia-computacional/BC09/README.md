# Biología Computacional — BC09: De secuencias homólogas a hipótesis evolutivas

| Campo | Valor |
|---|---|
| Versión | v4.0 |
| Edición | 2 |
| Responsable | Álvaro Serrano Navarro |
| Fecha | 2026-09-04 |
| Asignatura | Biología Computacional |
| Módulo | BC09 |

---

## Pregunta del tema

Un árbol filogenético parece un hecho y es una hipótesis: la mejor explicación de unos datos bajo un modelo concreto. ¿Qué parte de la forma de ese árbol viene de las secuencias y qué parte del modelo con que se han comparado?

## Producto final

Un módulo propio que calcule distancias observadas y corregidas con su dominio de validez, y un informe que documente, para tres variantes del mismo análisis, qué cambió el orden de fusión y qué solo la escala.

## Qué hay en esta carpeta

- `datos/` · los datos de partida con su manifiesto de sumas.
- `src/` · el generador del espacio de trabajo y el verificador de entrega.
- `paquete/BC09_practica_v4.0.tar.gz` · todo lo anterior empaquetado, que es
  la forma cómoda de descargarlo de una vez.

## Cómo empezar

    tar -xzf BC09_practica_v4.0.tar.gz
    cd BC-CH09
    ./practice_assets/create_workspace.sh entrega
    cd entrega

El generador crea la plantilla de su módulo **sin implementar** y la tabla de
respuestas con solo su cabecera. Antes de ejecutar nada, escriba lo que espera
obtener: el contraste entre predicción y resultado es lo que se evalúa.

## Cómo comprobar que ha terminado

    ./practice_assets/check_delivery.sh entrega

No pone nota. Rechaza la entrega vacía y el espacio de trabajo recién generado.
