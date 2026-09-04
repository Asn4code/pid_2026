# Biología Computacional — BC12: Modelado computacional de estructuras

| Campo | Valor |
|---|---|
| Versión | v4.0 |
| Edición | 2 |
| Responsable | Álvaro Serrano Navarro |
| Fecha | 2026-09-04 |
| Asignatura | Biología Computacional |
| Módulo | BC12 |

---

## Pregunta del tema

Una secuencia de aminoácidos determina una estructura, y esa estructura determina lo que la proteína hace. El salto del primer dato al segundo lleva medio siglo de trabajo y sigue teniendo métodos que fallan de maneras distintas. ¿Cómo se decide, ante una secuencia concreta, qué método puede usarse y cuánto hay que fiarse del modelo que devuelve?

## Producto final

Un módulo propio que calcule la identidad de secuencia, la probabilidad de aceptación de Metropolis con su guarda y el Clashscore de un modelo, y una tabla que sitúe cuatro pares de secuencias en la zona de fiabilidad que les corresponde, con la predicción anotada antes de ejecutar.

## Qué hay en esta carpeta

- `datos/` · los datos de partida con su manifiesto de sumas.
- `src/` · el generador del espacio de trabajo y el verificador de entrega.
- `paquete/BC12_practica_v4.0.tar.gz` · todo lo anterior empaquetado, que es
  la forma cómoda de descargarlo de una vez.

## Cómo empezar

    tar -xzf BC12_practica_v4.0.tar.gz
    cd BC-CH12
    ./practice_assets/create_workspace.sh entrega
    cd entrega

El generador crea la plantilla de su módulo **sin implementar** y la tabla de
respuestas con solo su cabecera. Antes de ejecutar nada, escriba lo que espera
obtener: el contraste entre predicción y resultado es lo que se evalúa.

## Cómo comprobar que ha terminado

    ./practice_assets/check_delivery.sh entrega

No pone nota. Rechaza la entrega vacía y el espacio de trabajo recién generado.
