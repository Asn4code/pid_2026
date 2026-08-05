# Práctica individual TC04: estructuras lineales sobre datos biológicos

**Versión:** 0.1.0

**Modalidad:** individual

**Tiempo orientativo:** 30 min de preparación + 90 min de trabajo + 20 min de comprobación

**Entorno:** vía A, GNU/Linux local; vía B, Google Colab

## Contrato de la práctica

**Pregunta:** ¿puedes usar la estructura lineal adecuada —array, pila o cola— para
resolver tres tareas biológicas, y justificar su coste?

**Producto:** un único `TC04_apellidos_nombre.tar.gz` con `datos/`, `scripts/`
(tres `.sh`), `resultados/`, `notas/` (README e history) y `pruebas.tsv`.

**Criterio de éxito:** los scripts pasan la comprobación de sintaxis, usan la
estructura correcta con el coste esperado, reproducen el oráculo del corpus y
pueden ejecutarse siguiendo el README.

**IA:** realiza sin IA la elección de estructura, las pruebas y la defensa. Audita
cualquier propuesta de IA preguntándote si su perfil de costes encaja con el uso.

## Antes de empezar: lectura del capítulo

Da por leído el capítulo de TC04. Necesitas manejar sin consultarlo:

- dato, tipo, estructura y la distinción TDA / implementación;
- almacenamiento contiguo (array) frente a enlazado (lista);
- costes O(1) y O(n) de acceso, búsqueda, inserción y borrado en cada estructura;
- pila (LIFO): `push`, `pop`, `peek`, y su uso en el emparejamiento de bases;
- cola (FIFO): `enqueue`, `dequeue`, y su papel en el recorrido en anchura.

## Dependencias didácticas

| Elemento utilizado | Se enseña antes en el capítulo |
|---|---|
| notación O y coste de operaciones | TC03 y S08 |
| array, acceso por índice y ventanas | S08: el array |
| lista enlazada y sus costes | S08: la lista enlazada |
| pila (LIFO) y emparejamiento de bases | S09: la pila |
| cola (FIFO) frente a pila | S09: la cola |
| arrays de Bash como pila y cola | TC01-TC02 y S09 |

## 1. Preparar y verificar el entorno

Elige una sola vía. En Linux:

```bash
sha256sum -c SHA256SUMS
tar -xzf TC04_starter_v0.1.0.tar.gz
cd TC04-starter
chmod +x src/smoke_test.sh
./src/smoke_test.sh --report resultados/smoke_test.tsv
```

Debe terminar con `TC04_SMOKE_TEST_OK`. Después:

```bash
./src/preparar_practica.sh ../TC04_apellidos_nombre
cd ../TC04_apellidos_nombre
```

En Windows o macOS usa el [cuaderno Colab de TC04](https://colab.research.google.com/github/Asn4code/pid_2026/blob/desarrollo/materiales/tecnicas-computacionales-biologia/TC04/notebooks/TC04_colab.ipynb).

## 2. Programa 1: `ventanas.sh` (array)

Recibe `FICHERO K` y, usando el acceso por índice de una cadena (array), imprime:

- `longitud: L` y `ventanas: L-K+1`;
- una línea `posicion<TAB>ventana` por cada ventana de longitud `K`.

Rechaza `K` no entero, `K` mayor que la longitud y fichero ausente. Sobre
`caso.fasta` con `K=3` hay **8** ventanas; la primera es `ATG` y la última `CGT`.
Explica en el README por qué el acceso por índice es O(1).

## 3. Programa 2: `pila.sh` (pila / LIFO)

Recibe `FICHERO` con una estructura de ARN en notación de puntos y paréntesis
(`(`, `)`, `.`). Con una **pila**, valida el emparejamiento e imprime:

- `resultado: equilibrado` o `resultado: desequilibrado`;
- `posicion: P` (0 si equilibrado; si no, la posición del primer fallo);
- `profundidad_maxima: D`.

Rechaza caracteres no válidos y fichero ausente. En el corpus,
`estructura_ok.txt` está equilibrada con profundidad **3**;
`estructura_extra_cierre.txt` falla en la posición **5**;
`estructura_extra_apertura.txt` falla en la **1**. Explica por qué un contador no
basta y la pila sí.

## 4. Programa 3: `cola.sh` (cola / FIFO frente a pila / LIFO)

Recibe `FICHERO` con un identificador por línea y, con una **cola** y una **pila**,
imprime:

- `elementos: N`;
- `cola (FIFO): ...` (mismo orden de entrada);
- `pila (LIFO): ...` (orden inverso).

En el corpus, `caso_ids.txt` da FIFO `read_1 read_2 read_3` y LIFO
`read_3 read_2 read_1`. Explica la diferencia entre los dos órdenes.

## 5. Validación obligatoria

```bash
bash -n scripts/ventanas.sh scripts/pila.sh scripts/cola.sh
chmod u+x scripts/*.sh
bash /ruta/al/paquete/TC04-starter/src/verificar_entrega.sh .
```

Debe terminar con `TC04_SUBMISSION_TESTS_OK`. Completa `pruebas.tsv` (columnas
`script  caso  esperado  real  estado_salida  OK_NO`) y `notas/README.md` con la
tabla de costes y la justificación de cada estructura. Al terminar:

```bash
history -a; history > notas/history.txt
cd ..; tar -czf TC04_apellidos_nombre.tar.gz TC04_apellidos_nombre/
tar -tzf TC04_apellidos_nombre.tar.gz | head -n 40
sha256sum TC04_apellidos_nombre.tar.gz
```

## 6. Lista final

- [ ] Los tres scripts pasan `bash -n` y son ejecutables.
- [ ] `ventanas.sh` cuenta `L-K+1` ventanas y rechaza `K` inválido.
- [ ] `pila.sh` usa una pila y detecta la posición del fallo.
- [ ] `cola.sh` da FIFO y LIFO sobre la misma entrada.
- [ ] El README incluye la tabla de costes y justifica cada estructura.
- [ ] `verificar_entrega.sh` termina con `TC04_SUBMISSION_TESTS_OK`.
- [ ] He inspeccionado el contenido del `tar.gz` antes de entregarlo.
