# Técnicas Computacionales en Biología — TC04: Representación en memoria y estructuras lineales

| Campo | Valor |
|---|---|
| Versión | v4.0 |
| Edición | 2 |
| Responsable | Álvaro Serrano Navarro |
| Fecha | 2026-09-04 |
| Asignatura | Técnicas Computacionales en Biología |
| Módulo | TC04 |

---

## Pregunta del tema

Dos programas guardan el mismo millón de lecturas y hacen las mismas operaciones sobre ellas. Uno tarda un segundo y el otro veinte minutos. ¿Qué decidió la diferencia, si el procesador es el mismo?

## Producto final

Una pila y una cola escritas por usted con arrays de Bash, capaces de validar el anidamiento de una estructura secundaria de ARN donde un contador falla, y de procesar lecturas respetando el orden de llegada.

## Qué hay en esta carpeta

- `datos/` · los datos de partida con su manifiesto de sumas.
- `src/` · el generador del espacio de trabajo y el verificador de entrega.
- `paquete/TC04_practica_v4.0.tar.gz` · todo lo anterior empaquetado, que es
  la forma cómoda de descargarlo de una vez.

## Cómo empezar

    tar -xzf TC04_practica_v4.0.tar.gz
    cd TC-CH04
    ./practice_assets/create_workspace.sh entrega
    cd entrega

El generador crea la plantilla de su módulo **sin implementar** y la tabla de
respuestas con solo su cabecera. Antes de ejecutar nada, escriba lo que espera
obtener: el contraste entre predicción y resultado es lo que se evalúa.

## Cómo comprobar que ha terminado

    ./practice_assets/check_entrega.sh entrega

No pone nota. Rechaza la entrega vacía y el espacio de trabajo recién generado.
