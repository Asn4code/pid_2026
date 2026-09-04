# Biología Computacional — BC08: Alineamiento de lecturas a secuencias de referencia

| Campo | Valor |
|---|---|
| Versión | v4.0 |
| Edición | 2 |
| Responsable | Álvaro Serrano Navarro |
| Fecha | 2026-09-04 |
| Asignatura | Biología Computacional |
| Módulo | BC08 |

---

## Pregunta del tema

Un experimento produce cientos de millones de lecturas de cien bases, y hay que decir de qué punto del genoma viene cada una. Comparar cada lectura con cada posición es inviable. ¿Qué se hace en su lugar, y qué se pierde al hacerlo?

## Producto final

Un índice de k-meros y un alineador por semilla y extensión escritos por usted, con el criterio de ambigüedad declarado: qué hacer cuando una lectura encaja igual de bien en dos sitios.

## Qué hay en esta carpeta

- `datos/` · los datos de partida con su manifiesto de sumas.
- `src/` · el generador del espacio de trabajo y el verificador de entrega.
- `paquete/BC08_practica_v4.0.tar.gz` · todo lo anterior empaquetado, que es
  la forma cómoda de descargarlo de una vez.

## Cómo empezar

    tar -xzf BC08_practica_v4.0.tar.gz
    cd BC-CH08
    ./practice_assets/create_workspace.sh entrega
    cd entrega

El generador crea la plantilla de su módulo **sin implementar** y la tabla de
respuestas con solo su cabecera. Antes de ejecutar nada, escriba lo que espera
obtener: el contraste entre predicción y resultado es lo que se evalúa.

## Cómo comprobar que ha terminado

    ./practice_assets/check_entrega.sh entrega

No pone nota. Rechaza la entrega vacía y el espacio de trabajo recién generado.
