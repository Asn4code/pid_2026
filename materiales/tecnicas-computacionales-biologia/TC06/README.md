# Técnicas Computacionales en Biología — TC06: Búsqueda, ordenación y evaluación experimental

| Campo | Valor |
|---|---|
| Versión | v4.0 |
| Edición | 2 |
| Responsable | Álvaro Serrano Navarro |
| Fecha | 2026-09-04 |
| Asignatura | Técnicas Computacionales en Biología |
| Módulo | TC06 |

---

## Pregunta del tema

Ordenar un millón de registros cuesta un trabajo que no había que hacer para responder una sola pregunta. ¿Cuándo compensa pagarlo por adelantado, y cuándo es tirar el tiempo?

## Producto final

Un conteo a mano de las comparaciones de la ordenación por selección, contrastado con la medición, y un veredicto razonado sobre el escalado real al duplicar la entrada.

## Qué hay en esta carpeta

- `datos/` · los datos de partida con su manifiesto de sumas.
- `src/` · el generador del espacio de trabajo y el verificador de entrega.
- `paquete/TC06_practica_v4.0.tar.gz` · todo lo anterior empaquetado, que es
  la forma cómoda de descargarlo de una vez.

## Cómo empezar

    tar -xzf TC06_practica_v4.0.tar.gz
    cd TC-CH06
    ./practice_assets/create_workspace.sh entrega
    cd entrega

El generador crea la plantilla de su módulo **sin implementar** y la tabla de
respuestas con solo su cabecera. Antes de ejecutar nada, escriba lo que espera
obtener: el contraste entre predicción y resultado es lo que se evalúa.

## Cómo comprobar que ha terminado

    ./practice_assets/check_entrega.sh entrega

No pone nota. Rechaza la entrega vacía y el espacio de trabajo recién generado.
