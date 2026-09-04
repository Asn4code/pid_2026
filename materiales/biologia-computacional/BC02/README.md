# Biología Computacional — BC02: Biomoléculas como objetos computables

| Campo | Valor |
|---|---|
| Versión | v4.0 |
| Edición | 2 |
| Responsable | Álvaro Serrano Navarro |
| Fecha | 2026-09-04 |
| Asignatura | Biología Computacional |
| Módulo | BC02 |

---

## Pregunta del tema

Una cadena de aminoácidos podría plegarse de más maneras que átomos hay en el universo, y sin embargo encuentra su forma correcta en microsegundos. ¿Qué restringe ese espacio, y qué propiedades de la proteína se pueden calcular sabiendo solo su secuencia?

## Producto final

Una clase en Python que represente una proteína, valide su alfabeto al construirla y calcule masa, composición y perfil de hidropatía, aplicada a localizar una región transmembrana.

## Qué hay en esta carpeta

- `datos/` · los datos de partida con su manifiesto de sumas.
- `src/` · el generador del espacio de trabajo y el verificador de entrega.
- `paquete/BC02_practica_v4.0.tar.gz` · todo lo anterior empaquetado, que es
  la forma cómoda de descargarlo de una vez.

## Cómo empezar

    tar -xzf BC02_practica_v4.0.tar.gz
    cd BC-CH02
    ./practice_assets/create_workspace.sh entrega
    cd entrega

El generador crea la plantilla de su módulo **sin implementar** y la tabla de
respuestas con solo su cabecera. Antes de ejecutar nada, escriba lo que espera
obtener: el contraste entre predicción y resultado es lo que se evalúa.

## Cómo comprobar que ha terminado

    ./practice_assets/check_entrega.sh entrega

No pone nota. Rechaza la entrega vacía y el espacio de trabajo recién generado.
