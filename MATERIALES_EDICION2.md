# Edición 2 de los materiales · v4.0

Publicada el 2026-09-04. Sustituye a las versiones `v2.2` de Técnicas
Computacionales en Biología y `v3.0` de Biología Computacional, que siguen
descargables por su nombre de fichero en `docs/assets/capitulos/`.

## Qué cambia

Los veinticuatro capítulos se han reeditado a partir de una auditoría por
capítulo. Los cambios con más efecto sobre el trabajo del alumnado:

- **Las órdenes impresas se ejecutan tal como se leen.** Antes había capítulos
  donde la mitad fallaba por argumentos o subcomandos que no existían.
- **El generador de la práctica reparte una plantilla vacía.** Antes varios
  entregaban la solución dentro.
- **El verificador de entrega discrimina.** Rechaza la entrega vacía y el
  espacio de trabajo recién generado, y no pone nota: la nota la pone quien
  corrige.
- **Las respuestas salen del PDF del alumnado** y viven en el material de
  corrección, que no se publica aquí.
- **Cada capítulo abre con su pregunta y su producto**, y declara qué se lee
  antes de clase y qué es de consulta.

## Novedades de esta versión

- **Los dos libros completos en un solo PDF**, etiquetado y conforme a PDF/UA-2:
  `docs/assets/libros/TC-libro_v4.0.pdf` (187 páginas) y `BC-libro_v4.0.pdf`
  (207 páginas).
- **TC10 · Aprendizaje automático** estrena materiales de práctica.
- **Paquetes prácticos por capítulo** en `materiales/<asignatura>/<COD>/paquete/`,
  con el generador del espacio de trabajo, los datos con su manifiesto de sumas,
  el oráculo del capítulo y el comprobador público.

## Qué se conserva

Los `notebooks/` y las plantillas de `entrega/` de cada capítulo no se han
tocado: la edición 2 no los genera y se mantienen como estaban.

## Qué no está aquí

El material de corrección —claves, soluciones de referencia y valores
esperados— no se publica en este repositorio. La herramienta de volcado aborta
si detecta cualquier ruta de clave.
