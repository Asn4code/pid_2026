# Biología Computacional — BC10: Regulación génica, clonación y vectores recombinantes

| Campo | Valor |
|---|---|
| Versión | v4.0 |
| Edición | 2 |
| Responsable | Álvaro Serrano Navarro |
| Fecha | 2026-09-04 |
| Asignatura | Biología Computacional |
| Módulo | BC10 |

---

## Pregunta del tema

Un operón bacteriano decide cuándo transcribir sus genes con una lógica que se puede escribir en tres líneas de código. La misma idea, invertida, permite construir un plásmido: si sabemos qué señales lee la célula, podemos escribirlas nosotros. ¿Qué parte del diseño de un constructo es biología y qué parte es cálculo sobre una cadena de texto?

## Producto final

Un módulo propio que calcule el porcentaje de guanina y citosina y la temperatura de fusión de un cebador, localice dianas de restricción en una secuencia y rechace las entradas fuera de dominio, con una tabla de predicciones contrastadas contra la ejecución.

## Qué hay en esta carpeta

- `datos/` · los datos de partida con su manifiesto de sumas.
- `src/` · el generador del espacio de trabajo y el verificador de entrega.
- `paquete/BC10_practica_v4.0.tar.gz` · todo lo anterior empaquetado, que es
  la forma cómoda de descargarlo de una vez.

## Cómo empezar

    tar -xzf BC10_practica_v4.0.tar.gz
    cd BC-CH10
    ./practice_assets/create_workspace.sh entrega
    cd entrega

El generador crea la plantilla de su módulo **sin implementar** y la tabla de
respuestas con solo su cabecera. Antes de ejecutar nada, escriba lo que espera
obtener: el contraste entre predicción y resultado es lo que se evalúa.

## Cómo comprobar que ha terminado

    ./practice_assets/check_delivery.sh entrega

No pone nota. Rechaza la entrega vacía y el espacio de trabajo recién generado.
