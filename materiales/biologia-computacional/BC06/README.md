# Biología Computacional — BC06: Tecnologías de secuenciación y diseño experimental

| Campo | Valor |
|---|---|
| Versión | v4.0 |
| Edición | 2 |
| Responsable | Álvaro Serrano Navarro |
| Fecha | 2026-09-04 |
| Asignatura | Biología Computacional |
| Módulo | BC06 |

---

## Pregunta del tema

Secuenciar el primer genoma humano costó unos tres mil millones de dólares y trece años. Hoy se hace en un día por menos de mil. ¿Qué cambió exactamente, y qué decisiones hay que tomar antes de encargar una secuenciación para que los datos sirvan?

## Producto final

Una calculadora de dimensionamiento escrita por usted que, dado un genoma y una profundidad objetivo, diga cuántas lecturas hacen falta, y que avise cuando los parámetros no tengan sentido físico.

## Qué hay en esta carpeta

- `datos/` · los datos de partida con su manifiesto de sumas.
- `src/` · el generador del espacio de trabajo y el verificador de entrega.
- `paquete/BC06_practica_v4.0.tar.gz` · todo lo anterior empaquetado, que es
  la forma cómoda de descargarlo de una vez.

## Cómo empezar

    tar -xzf BC06_practica_v4.0.tar.gz
    cd BC-CH06
    ./practice_assets/create_workspace.sh entrega
    cd entrega

El generador crea la plantilla de su módulo **sin implementar** y la tabla de
respuestas con solo su cabecera. Antes de ejecutar nada, escriba lo que espera
obtener: el contraste entre predicción y resultado es lo que se evalúa.

## Cómo comprobar que ha terminado

    ./practice_assets/check_entrega.sh entrega

No pone nota. Rechaza la entrega vacía y el espacio de trabajo recién generado.
