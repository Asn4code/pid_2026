# Técnicas Computacionales en Biología — TC10: Redes neuronales para bioinformática

| Campo | Valor |
|---|---|
| Versión | v4.0 |
| Edición | 2 |
| Responsable | Álvaro Serrano Navarro |
| Fecha | 2026-09-04 |
| Asignatura | Técnicas Computacionales en Biología |
| Módulo | TC10 |

---

## Pregunta del tema

¿Cómo puede un programa aprender por sí mismo a distinguir un enhancer activo de uno inactivo a partir de señales epigenéticas, y qué garantías tenemos de que lo que ha aprendido sirva en un hospital distinto del que produjo los datos?

## Producto final

El cálculo a mano, verificado con un oráculo, de una pasada completa de entrenamiento de una red pequeña, incluido el paso hacia atrás hasta la capa oculta, más una auditoría del diseño de validación que evite la fuga de datos por paciente.

## Qué hay en esta carpeta

- `datos/` · los datos de partida con su manifiesto de sumas.
- `src/` · el generador del espacio de trabajo y el verificador de entrega.
- `paquete/TC10_practica_v4.0.tar.gz` · todo lo anterior empaquetado, que es
  la forma cómoda de descargarlo de una vez.

## Cómo empezar

    tar -xzf TC10_practica_v4.0.tar.gz
    cd TC-CH10
    ./practice_assets/create_workspace.sh entrega
    cd entrega

El generador crea la plantilla de su módulo **sin implementar** y la tabla de
respuestas con solo su cabecera. Antes de ejecutar nada, escriba lo que espera
obtener: el contraste entre predicción y resultado es lo que se evalúa.

## Cómo comprobar que ha terminado

    ./practice_assets/check_entrega.sh entrega

No pone nota. Rechaza la entrega vacía y el espacio de trabajo recién generado.
