# Técnicas Computacionales en Biología — TC01: Entorno Linux, Shell y reproducibilidad

| Campo | Valor |
|---|---|
| Versión | v4.0 |
| Edición | 2 |
| Responsable | Álvaro Serrano Navarro |
| Fecha | 2026-09-04 |
| Asignatura | Técnicas Computacionales en Biología |
| Módulo | TC01 |

---

## Pregunta del tema

¿Qué ocurre exactamente entre que teclea una orden y obtiene un resultado, y cómo consigue que otra persona pueda reproducir ese resultado en su propia máquina?

## Producto final

Un espacio de trabajo Linux explorado sin alterarlo, con el entorno registrado, las operaciones peligrosas comprobadas antes de ejecutarlas y una entrega empaquetada cuya integridad se verifica con sha256sum.

## Qué hay en esta carpeta

- `datos/` · los datos de partida con su manifiesto de sumas.
- `src/` · el generador del espacio de trabajo y el verificador de entrega.
- `paquete/TC01_practica_v4.0.tar.gz` · todo lo anterior empaquetado, que es
  la forma cómoda de descargarlo de una vez.

## Cómo empezar

    tar -xzf TC01_practica_v4.0.tar.gz
    cd TC-CH01
    ./practice_assets/create_workspace.sh entrega
    cd entrega

El generador crea la plantilla de su módulo **sin implementar** y la tabla de
respuestas con solo su cabecera. Antes de ejecutar nada, escriba lo que espera
obtener: el contraste entre predicción y resultado es lo que se evalúa.

## Cómo comprobar que ha terminado

    ./practice_assets/check_entrega.sh entrega

No pone nota. Rechaza la entrega vacía y el espacio de trabajo recién generado.
