# Técnicas Computacionales en Biología — TC07: Medir sorpresa e incertidumbre

| Campo | Valor |
|---|---|
| Versión | v4.0 |
| Edición | 2 |
| Responsable | Álvaro Serrano Navarro |
| Fecha | 2026-09-04 |
| Asignatura | Técnicas Computacionales en Biología |
| Módulo | TC07 |

---

## Pregunta del tema

Dos mensajes de cuatro letras ocupan lo mismo en disco y no dicen lo mismo. ¿Cuánta incertidumbre había antes de leerlos, y cómo se mide eso con un número?

## Producto final

Un guion propio que calcula entropía por ventanas sobre una secuencia, con su contrato declarado y su comportamiento ante entradas que no son ADN, contrastado con un oráculo que no le da los valores de antemano.

## Qué hay en esta carpeta

- `datos/` · los datos de partida con su manifiesto de sumas.
- `src/` · el generador del espacio de trabajo y el verificador de entrega.
- `paquete/TC07_practica_v4.0.tar.gz` · todo lo anterior empaquetado, que es
  la forma cómoda de descargarlo de una vez.

## Cómo empezar

    tar -xzf TC07_practica_v4.0.tar.gz
    cd TC-CH07
    ./practice_assets/create_workspace.sh entrega
    cd entrega

El generador crea la plantilla de su módulo **sin implementar** y la tabla de
respuestas con solo su cabecera. Antes de ejecutar nada, escriba lo que espera
obtener: el contraste entre predicción y resultado es lo que se evalúa.

## Cómo comprobar que ha terminado

    ./practice_assets/check_submission_public.sh entrega

No pone nota. Rechaza la entrega vacía y el espacio de trabajo recién generado.
