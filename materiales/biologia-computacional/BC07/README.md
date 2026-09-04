# Biología Computacional — BC07: Formatos de secuencias y control de calidad

| Campo | Valor |
|---|---|
| Versión | v4.0 |
| Edición | 2 |
| Responsable | Álvaro Serrano Navarro |
| Fecha | 2026-09-04 |
| Asignatura | Biología Computacional |
| Módulo | BC07 |

---

## Pregunta del tema

Un secuenciador no entrega letras: entrega letras con una probabilidad de estar equivocadas. ¿Cómo se lee ese número, y qué se hace con las lecturas que no lo pasan?

## Producto final

Un módulo propio que lea el formato de lecturas con calidades, convierta los caracteres a puntuaciones y recorte por ventana deslizante, con el criterio de corte declarado.

## Qué hay en esta carpeta

- `datos/` · los datos de partida con su manifiesto de sumas.
- `src/` · el generador del espacio de trabajo y el verificador de entrega.
- `paquete/BC07_practica_v4.0.tar.gz` · todo lo anterior empaquetado, que es
  la forma cómoda de descargarlo de una vez.

## Cómo empezar

    tar -xzf BC07_practica_v4.0.tar.gz
    cd BC-CH07
    ./practice_assets/create_workspace.sh entrega
    cd entrega

El generador crea la plantilla de su módulo **sin implementar** y la tabla de
respuestas con solo su cabecera. Antes de ejecutar nada, escriba lo que espera
obtener: el contraste entre predicción y resultado es lo que se evalúa.

## Cómo comprobar que ha terminado

    ./practice_assets/check_entrega.sh entrega

No pone nota. Rechaza la entrega vacía y el espacio de trabajo recién generado.
