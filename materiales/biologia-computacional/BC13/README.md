# Biología Computacional — BC13: Aprendizaje profundo, redes neuronales y AlphaFold en biología estructural

| Campo | Valor |
|---|---|
| Versión | v4.0 |
| Edición | 2 |
| Responsable | Álvaro Serrano Navarro |
| Fecha | 2026-09-04 |
| Asignatura | Biología Computacional |
| Módulo | BC13 |

---

## Pregunta del tema

AlphaFold devuelve coordenadas atómicas completas para cualquier secuencia que se le dé, incluidas las que no se pliegan. El modelo nunca dice «no lo sé»: lo dice el pLDDT y lo dice la matriz PAE, en otro sitio y en otra escala. ¿Cómo se lee una predicción para saber qué parte de ella es una afirmación y qué parte es una conjetura?

## Producto final

Un módulo propio que clasifique las bandas de pLDDT, calcule la confianza media, distinga por la matriz PAE una orientación rígida entre dominios de una bisagra flexible y compruebe la consistencia geométrica del modelo, con un informe que dictamine cuatro modelos predichos y diga para qué sirve cada uno.

## Qué hay en esta carpeta

- `datos/` · los datos de partida con su manifiesto de sumas.
- `src/` · el generador del espacio de trabajo y el verificador de entrega.
- `paquete/BC13_practica_v4.0.tar.gz` · todo lo anterior empaquetado, que es
  la forma cómoda de descargarlo de una vez.

## Cómo empezar

    tar -xzf BC13_practica_v4.0.tar.gz
    cd BC-CH13
    ./practice_assets/create_workspace.sh entrega
    cd entrega

El generador crea la plantilla de su módulo **sin implementar** y la tabla de
respuestas con solo su cabecera. Antes de ejecutar nada, escriba lo que espera
obtener: el contraste entre predicción y resultado es lo que se evalúa.

## Cómo comprobar que ha terminado

    ./practice_assets/check_delivery.sh entrega

No pone nota. Rechaza la entrega vacía y el espacio de trabajo recién generado.
