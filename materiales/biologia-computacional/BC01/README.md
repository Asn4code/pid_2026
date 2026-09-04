# Biología Computacional — BC01: La información biológica y su representación en Python

| Campo | Valor |
|---|---|
| Versión | v4.0 |
| Edición | 2 |
| Responsable | Álvaro Serrano Navarro |
| Fecha | 2026-09-04 |
| Asignatura | Biología Computacional |
| Módulo | BC01 |

---

## Pregunta del tema

Una cadena de texto con cuatro letras distintas puede ser un fichero cualquiera o el programa completo de un ser vivo. ¿Qué convierte una secuencia de ADN en información, y qué operaciones sobre ella significan algo biológico y no solo sintáctico?

## Producto final

Un módulo propio en Python que calcule contenido GC, complemento reverso, transcripción y perfiles por ventana, con una guarda que rechace lo que no es ADN.

## Qué hay en esta carpeta

- `datos/` · los datos de partida con su manifiesto de sumas.
- `src/` · el generador del espacio de trabajo y el verificador de entrega.
- `paquete/BC01_practica_v4.0.tar.gz` · todo lo anterior empaquetado, que es
  la forma cómoda de descargarlo de una vez.

## Cómo empezar

    tar -xzf BC01_practica_v4.0.tar.gz
    cd BC-CH01
    ./practice_assets/create_workspace.sh entrega
    cd entrega

El generador crea la plantilla de su módulo **sin implementar** y la tabla de
respuestas con solo su cabecera. Antes de ejecutar nada, escriba lo que espera
obtener: el contraste entre predicción y resultado es lo que se evalúa.

## Cómo comprobar que ha terminado

    ./practice_assets/check_entrega.sh entrega

No pone nota. Rechaza la entrega vacía y el espacio de trabajo recién generado.
