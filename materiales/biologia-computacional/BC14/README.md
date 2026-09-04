# Biología Computacional — BC14: Cribado virtual y diseño computacional de fármacos

| Campo | Valor |
|---|---|
| Versión | v4.0 |
| Edición | 2 |
| Responsable | Álvaro Serrano Navarro |
| Fecha | 2026-09-04 |
| Asignatura | Biología Computacional |
| Módulo | BC14 |

---

## Pregunta del tema

Ante cientos de millones de compuestos disponibles y una diana con estructura conocida, ¿cómo se eligen los cinco que merece la pena sintetizar y probar, y cómo se explica por qué esos y no otros?

## Producto final

Un módulo propio en Python que evalúe la regla de cinco, la similitud de Tanimoto, una afinidad ilustrativa y un paso de integración, aplicado a diez compuestos para producir un ranking razonado con un control positivo y dos señuelos identificados.

## Qué hay en esta carpeta

- `datos/` · los datos de partida con su manifiesto de sumas.
- `src/` · el generador del espacio de trabajo y el verificador de entrega.
- `paquete/BC14_practica_v4.0.tar.gz` · todo lo anterior empaquetado, que es
  la forma cómoda de descargarlo de una vez.

## Cómo empezar

    tar -xzf BC14_practica_v4.0.tar.gz
    cd BC-CH14
    ./practice_assets/create_workspace.sh entrega
    cd entrega

El generador crea la plantilla de su módulo **sin implementar** y la tabla de
respuestas con solo su cabecera. Antes de ejecutar nada, escriba lo que espera
obtener: el contraste entre predicción y resultado es lo que se evalúa.

## Cómo comprobar que ha terminado

    ./practice_assets/check_delivery.sh entrega

No pone nota. Rechaza la entrega vacía y el espacio de trabajo recién generado.
