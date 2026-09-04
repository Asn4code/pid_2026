# Biología Computacional — BC03: Genomas, epigenética y variantes

| Campo | Valor |
|---|---|
| Versión | v4.0 |
| Edición | 2 |
| Responsable | Álvaro Serrano Navarro |
| Fecha | 2026-09-04 |
| Asignatura | Biología Computacional |
| Módulo | BC03 |

---

## Pregunta del tema

Solo el dos por ciento del genoma humano codifica proteínas. ¿Qué hace el resto, y cómo se decide si un cambio de una sola letra en cualquier punto de esos tres mil millones importa o no?

## Producto final

Un procesador de variantes escrito por usted que lea el formato estándar, convierta bien las coordenadas, clasifique cada cambio y calcule el indicador de calidad del lote, avisando cuando se sale de lo esperado.

## Qué hay en esta carpeta

- `datos/` · los datos de partida con su manifiesto de sumas.
- `src/` · el generador del espacio de trabajo y el verificador de entrega.
- `paquete/BC03_practica_v4.0.tar.gz` · todo lo anterior empaquetado, que es
  la forma cómoda de descargarlo de una vez.

## Cómo empezar

    tar -xzf BC03_practica_v4.0.tar.gz
    cd BC-CH03
    ./practice_assets/create_workspace.sh entrega
    cd entrega

El generador crea la plantilla de su módulo **sin implementar** y la tabla de
respuestas con solo su cabecera. Antes de ejecutar nada, escriba lo que espera
obtener: el contraste entre predicción y resultado es lo que se evalúa.

## Cómo comprobar que ha terminado

    ./practice_assets/check_entrega.sh entrega

No pone nota. Rechaza la entrega vacía y el espacio de trabajo recién generado.
