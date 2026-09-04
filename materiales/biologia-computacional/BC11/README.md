# Biología Computacional — BC11: Estructura tridimensional de proteínas

| Campo | Valor |
|---|---|
| Versión | v4.0 |
| Edición | 2 |
| Responsable | Álvaro Serrano Navarro |
| Fecha | 2026-09-04 |
| Asignatura | Biología Computacional |
| Módulo | BC11 |

---

## Pregunta del tema

Una estructura de un banco de datos no es una observación directa: es un modelo ajustado a una medida indirecta. ¿Cómo se obtiene, qué se puede creer de ella y qué comprobaciones hay que hacer antes de usarla?

## Producto final

Un procesador de ficheros de estructura escrito por usted que valide el formato línea a línea, extraiga las coordenadas y los factores de temperatura, y emita un informe de validación con las señales de alarma que el capítulo enumera.

## Qué hay en esta carpeta

- `datos/` · los datos de partida con su manifiesto de sumas.
- `src/` · el generador del espacio de trabajo y el verificador de entrega.
- `paquete/BC11_practica_v4.0.tar.gz` · todo lo anterior empaquetado, que es
  la forma cómoda de descargarlo de una vez.

## Cómo empezar

    tar -xzf BC11_practica_v4.0.tar.gz
    cd BC-CH11
    ./practice_assets/create_workspace.sh entrega
    cd entrega

El generador crea la plantilla de su módulo **sin implementar** y la tabla de
respuestas con solo su cabecera. Antes de ejecutar nada, escriba lo que espera
obtener: el contraste entre predicción y resultado es lo que se evalúa.

## Cómo comprobar que ha terminado

    ./practice_assets/check_entrega.sh entrega

No pone nota. Rechaza la entrega vacía y el espacio de trabajo recién generado.
