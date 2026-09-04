# Biología Computacional — BC04: Transcripción, procesado de ARN y expresión génica

| Campo | Valor |
|---|---|
| Versión | v4.0 |
| Edición | 2 |
| Responsable | Álvaro Serrano Navarro |
| Fecha | 2026-09-04 |
| Asignatura | Biología Computacional |
| Módulo | BC04 |

---

## Pregunta del tema

Dos células con el mismo genoma pueden ser una neurona y un hepatocito. La diferencia no está en el texto sino en qué partes se leen y cuántas veces. ¿Cómo se mide eso, y por qué el número bruto de lecturas de un experimento no sirve como medida?

## Producto final

Un módulo propio que localice marcos abiertos de lectura en los seis marcos, traduzca el más largo y normalice una tabla de expresión, comprobando la propiedad que hace comparables los valores entre muestras.

## Qué hay en esta carpeta

- `datos/` · los datos de partida con su manifiesto de sumas.
- `src/` · el generador del espacio de trabajo y el verificador de entrega.
- `paquete/BC04_practica_v4.0.tar.gz` · todo lo anterior empaquetado, que es
  la forma cómoda de descargarlo de una vez.

## Cómo empezar

    tar -xzf BC04_practica_v4.0.tar.gz
    cd BC-CH04
    ./practice_assets/create_workspace.sh entrega
    cd entrega

El generador crea la plantilla de su módulo **sin implementar** y la tabla de
respuestas con solo su cabecera. Antes de ejecutar nada, escriba lo que espera
obtener: el contraste entre predicción y resultado es lo que se evalúa.

## Cómo comprobar que ha terminado

    ./practice_assets/check_entrega.sh entrega

No pone nota. Rechaza la entrega vacía y el espacio de trabajo recién generado.
