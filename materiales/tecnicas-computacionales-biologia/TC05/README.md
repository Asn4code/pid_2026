# Técnicas Computacionales en Biología — TC05: Tablas hash, árboles y grafos

| Campo | Valor |
|---|---|
| Versión | v4.0 |
| Edición | 2 |
| Responsable | Álvaro Serrano Navarro |
| Fecha | 2026-09-04 |
| Asignatura | Técnicas Computacionales en Biología |
| Módulo | TC05 |

---

## Pregunta del tema

Ninguna estructura lineal consigue a la vez búsqueda barata e inserción barata. ¿Qué hay que cambiar para romper ese compromiso, y qué se paga a cambio?

## Producto final

Una tabla de dispersión de codones y un recorrido de grafo escritos por usted, y un veredicto razonado sobre qué nodo de una red de interacción es realmente crítico, sostenido por el cálculo y no por la intuición del grado.

## Qué hay en esta carpeta

- `datos/` · los datos de partida con su manifiesto de sumas.
- `src/` · el generador del espacio de trabajo y el verificador de entrega.
- `paquete/TC05_practica_v4.0.tar.gz` · todo lo anterior empaquetado, que es
  la forma cómoda de descargarlo de una vez.

## Cómo empezar

    tar -xzf TC05_practica_v4.0.tar.gz
    cd TC-CH05
    ./practice_assets/create_workspace.sh entrega
    cd entrega

El generador crea la plantilla de su módulo **sin implementar** y la tabla de
respuestas con solo su cabecera. Antes de ejecutar nada, escriba lo que espera
obtener: el contraste entre predicción y resultado es lo que se evalúa.

## Cómo comprobar que ha terminado

    ./practice_assets/check_entrega.sh entrega

No pone nota. Rechaza la entrega vacía y el espacio de trabajo recién generado.
