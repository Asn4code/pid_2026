# Práctica individual TC03: medir, comparar y explicar el coste de un algoritmo

**Versión:** 0.1.0

**Modalidad:** individual

**Tiempo orientativo:** 30 min de preparación + 90 min de trabajo + 20 min de comprobación

**Entorno:** vía A, GNU/Linux local; vía B, Google Colab

## Contrato de la práctica

**Pregunta:** ¿puedes convertir el análisis de un algoritmo en tres scripts que
midan su coste, comparen dos estrategias y expliquen cómo crece con el tamaño de
la entrada?

**Producto:** un único `TC03_apellidos_nombre.tar.gz` con esta estructura:

```text
TC03_apellidos_nombre/
├── datos/                 # entradas facilitadas, sin modificar
├── scripts/               # tres scripts .sh ejecutables
├── resultados/            # salidas pequeñas solicitadas
├── notas/
│   ├── README.md
│   └── history.txt
└── pruebas.tsv            # caso, resultado esperado, real y estado
```

**Criterio de éxito:** los scripts pasan la comprobación de sintaxis, cuentan las
operaciones de forma reproducible, distinguen la búsqueda lineal de la binaria y
la fuerza bruta de su coste, no sobrescriben datos, reproducen el oráculo del
corpus y pueden ejecutarse siguiendo el README.

**IA:** realiza sin IA la predicción del coste, las pruebas, la interpretación de
los resultados y la defensa. Si se autoriza una fase de auditoría con IA,
conserva la propuesta, identifica al menos un supuesto verificable —por ejemplo,
la clase de complejidad que afirma— y documenta cómo lo probaste; una salida de
IA no sustituye la evidencia.

## Antes de empezar: lectura del capítulo

Esta práctica da por leído el capítulo de TC03. Necesitas manejar sin consultarlo:

- la diferencia entre **representar** un algoritmo (lenguaje natural,
  pseudocódigo, código) y ejecutarlo;
- que el coste se mide **contando operaciones elementales en función de `n`**, no
  en segundos, porque los segundos dependen de la máquina;
- la **notación O** y por qué nos quedamos con el término dominante: O(1),
  O(log n), O(n), O(n·m), O(n²);
- las cuatro técnicas de diseño (fuerza bruta, voraz, divide y vencerás,
  programación dinámica) y cuándo la búsqueda binaria descarta la mitad del
  espacio en cada paso.

## Dependencias didácticas

| Elemento utilizado | Se enseña antes en el capítulo |
|---|---|
| representación de algoritmos y pseudocódigo | S06: qué es un algoritmo y cómo se representa |
| coste, operaciones elementales y notación O | S06: el coste de un algoritmo y el lenguaje O |
| búsqueda lineal frente a binaria, O(n) frente a O(log n) | S06: coste comparado sobre datos ordenados |
| fuerza bruta y su coste O(n·m) sobre subcadenas | S07: técnicas de diseño; fuerza bruta |
| crecimiento lineal frente a cuadrático y peor caso | S07: comparación empírica del escalado |
| Bash, argumentos, comillas, bucles, aritmética entera y estados de salida | TC01: de órdenes interactivas a scripts |

La práctica reutiliza el Bash de TC01 como herramienta; el contenido nuevo es el
**análisis de coste**. No exige medir tiempos con `time` ni implementar
programación dinámica: esos contenidos pertenecen a módulos posteriores.

## 1. Preparar y verificar el entorno

Requisitos comunes: 1 GB de RAM disponible, menos de 1 MB de disco para los
datos, acceso al paquete versionado y ninguna GPU. Linux local requiere Bash 4 o
posterior y utilidades GNU. La vía Colab requiere una sesión autorizada por el
estudiante, pero no recibe la entrega.

Documentación de referencia: [línea de comandos en
Ubuntu](https://documentation.ubuntu.com/desktop/en/latest/tutorial/the-linux-command-line-for-beginners/)
y [preguntas frecuentes de Google
Colab](https://research.google.com/colaboratory/faq.html). La vía Linux se
comprobó el 20-07-2026 con Bash 5.1.8; el informe registra la versión concreta de
cada ejecución.

Elige una sola vía. Si tienes GNU/Linux, trabaja en una terminal local con el
paquete enlazado desde el Campus. Si utilizas Windows o macOS, abre una copia
individual del [cuaderno Colab de
TC03](https://colab.research.google.com/github/Asn4code/pid_2026/blob/desarrollo/materiales/tecnicas-computacionales-biologia/TC03/notebooks/TC03_colab.ipynb).

Las dos vías utilizan los mismos datos y criterios. En Colab, cada celda `%%bash`
abre una Shell nueva: mantén `cd` y las órdenes dependientes en la misma celda y
descarga los resultados antes de terminar la sesión.

Si has descargado el archivo de inicio en Linux, verifica y extrae desde la
carpeta que contiene ambos ficheros:

```bash
sha256sum -c SHA256SUMS
tar -xzf TC03_starter_v0.1.0.tar.gz
cd TC03-starter
```

Ejecuta primero la prueba rápida del paquete:

```bash
chmod +x src/smoke_test.sh
./src/smoke_test.sh --report resultados/smoke_test.tsv
```

Debe terminar con `TC03_SMOKE_TEST_OK`. Después crea tu proyecto sin modificar el
paquete original:

```bash
./src/preparar_practica.sh ../TC03_apellidos_nombre
cd ../TC03_apellidos_nombre
```

Conserva `smoke_test.tsv` y registra también:

```bash
whoami
uname -s
bash --version
pwd
printf 'Shell actual: %s\n' "$0"
```

Registra las salidas relevantes en `notas/README.md`. No cambies de vía a mitad
de la práctica sin documentarlo. Si Colab falla, la entrega se mantendrá abierta
y la ejecución se reprogramará en Linux sin penalización.

### Diagnóstico de setup

| Síntoma | Comprobación | Solución |
|---|---|---|
| `Permission denied` al iniciar un script | `ls -l src/` | `chmod +x src/*.sh` o ejecutarlo con `bash` |
| `No such file or directory` | `pwd` y `ls` sobre cada componente | volver a la raíz de `TC03-starter`; no adivinar rutas |
| falla el checksum | repetir la descarga sin editar el archivo | no continuar con datos o paquete alterados |
| un script muere sin mensaje al contar | `bash -n` y revisar `((var++))` bajo `set -e` | usar `var=$((var+1))` para incrementar contadores |
| Colab perdió los ficheros | comprobar `/content` | ejecutar de nuevo la sección de descarga; el cuaderno conserva un proyecto existente |
| Colab no está disponible | registrar el incidente en el Campus | reprogramar la ejecución en Linux sin penalización |

## 2. Preparar el espacio de trabajo

1. Comprueba que `preparar_practica.sh` ha copiado el corpus a `datos/` y conserva intacto el paquete recibido.
2. Desde la raíz de tu proyecto, inspecciona una lista de enteros y un FASTA con `head`, `wc -l` y `sort -c -n`.
3. Anota una **predicción del coste** de cada programa antes de implementarlo: ¿cuántas comparaciones esperas en el peor caso de una lista de 31 elementos con búsqueda lineal y con binaria?
4. No uses `rm` sobre los datos originales.

El corpus docente sintético 0.1.0 contiene tres listas de enteros ordenadas
(`enteros_07.txt`, `enteros_15.txt`, `enteros_31.txt`), cinco ficheros FASTA
—uno con espacios en el nombre—, el caso conocido `caso_busqueda.txt`, el caso
`caso_motivo.fasta` y `tamanos.txt`. Si el docente entrega una variante, prevalece
el manifiesto que la acompaña y debes calcular los resultados, no copiarlos de
este texto.

## 3. Caso mínimo antes del corpus

Antes de automatizar, razona a mano sobre `datos/caso_busqueda.txt` (15 enteros
ordenados). Para el objetivo `33`:

- ¿en qué posición está y cuántas comparaciones hace una búsqueda **lineal** que
  recorre de izquierda a derecha?
- ¿cuántas hace una búsqueda **binaria** que descarta la mitad en cada paso?

Escribe tu predicción en `pruebas.tsv` antes de ejecutar nada. Después, sobre
`datos/caso_motivo.fasta`, cuenta a mano cuántas veces aparece el motivo `ATG`
—incluidas las apariciones solapadas— y contrasta tu recuento con el del programa
2. Conserva una prueba con resultado positivo y otra con resultado nulo.

## 4. Programa 1: búsqueda lineal frente a binaria

Escribe `scripts/buscar.sh`. Debe recibir exactamente `FICHERO OBJETIVO` y:

1. leer una lista de enteros, uno por línea, y rechazar contenidos no enteros;
2. rechazar con estado distinto de cero un objetivo no entero, un fichero ausente y una lista **no ordenada** de forma ascendente;
3. ejecutar una búsqueda **lineal** contando una comparación por elemento examinado;
4. ejecutar una búsqueda **binaria** contando una comparación (sonda) por iteración;
5. imprimir, con estas líneas exactas para que la comprobación las reconozca:

```text
== <nombre_del_fichero> ==
objetivo: <objetivo>
elementos: <n>
lineal: <posicion P|ausente> (<C> comparaciones)
binaria: <posicion P|ausente> (<C> comparaciones)
```

Prueba objetivo presente al principio, en medio y al final; objetivo ausente;
lista desordenada; y objetivo no entero. En `caso_busqueda.txt`, el objetivo `33`
debe dar **8 comparaciones lineales y 1 binaria**; el objetivo `34`, ausente, da
**15 y 4**. Explica en el README por qué la binaria exige una lista ordenada.

## 5. Programa 2: búsqueda de un motivo por fuerza bruta

Escribe `scripts/motivo.sh`. Debe recibir exactamente `FICHERO_FASTA MOTIVO` y:

1. concatenar solo las líneas de secuencia (descarta las cabeceras `^>`) y normalizar a mayúsculas;
2. rechazar con estado distinto de cero un fichero ausente y un motivo que no sea una cadena no vacía de `A`, `C`, `G`, `T` o `N`;
3. buscar el motivo por **fuerza bruta**, probando cada posición de inicio y comparando carácter a carácter hasta el primer fallo;
4. contar **todas** las ocurrencias, incluidas las solapadas, y el número total de comparaciones de caracteres;
5. imprimir, con estas líneas exactas:

```text
== <nombre_del_fichero> ==
motivo: <motivo>
longitud_secuencia: <L>
ocurrencias: <k>
posiciones: <p1 p2 ...|ninguna>
comparaciones: <total>
```

Prueba un motivo presente varias veces, uno ausente y uno solapado. En el corpus,
`adn_3.fasta` con `ATG` da **5 ocurrencias y 23 comparaciones**; `adn_4.fasta` con
`ATG`, **0 ocurrencias**; y `adn_4.fasta` con `CG`, **8 ocurrencias**. Explica en
el README por qué el coste de la fuerza bruta es O(n·m).

## 6. Programa 3: crecimiento lineal frente a cuadrático

Escribe `scripts/escalado.sh`. Por defecto lee `datos/tamanos.txt`; opcionalmente
acepta otro fichero de tamaños como primer argumento. Debe:

1. leer una lista de enteros positivos, uno por línea, y rechazar cualquier valor no válido;
2. para cada tamaño `n`, ejecutar de verdad un bucle **lineal** (que cuenta `n` operaciones) y un doble bucle **cuadrático** (que cuenta las `n·(n−1)/2` comparaciones por pares);
3. escribir `resultados/escalado.tsv` con la cabecera `n<TAB>lineal<TAB>cuadratica` y una fila por tamaño, ordenada de forma reproducible y sin duplicar filas al repetir la ejecución;
4. fallar con un mensaje claro si un tamaño no es un entero positivo.

Con `datos/tamanos.txt` (2, 4, 8, 16, 32) la columna cuadrática debe valer 1, 6,
28, 120 y 496. Explica en el README qué le ocurre a esa columna cuando `n` se
duplica y por qué eso es la firma de O(n²).

## 7. Validación obligatoria

Antes de empaquetar:

```bash
bash -n scripts/buscar.sh
bash -n scripts/motivo.sh
bash -n scripts/escalado.sh
chmod u+x scripts/*.sh
bash /ruta/al/paquete/TC03-starter/src/verificar_entrega.sh .
```

En Colab, la ruta del último comando es
`/content/TC03-starter/src/verificar_entrega.sh`. La prueba automática comprueba
el contrato técnico y los números del oráculo, pero no sustituye `pruebas.tsv`, la
interpretación ni la defensa individual.

Completa `pruebas.tsv` con las columnas:

```text
script	caso	esperado	real	estado_salida	OK_NO
```

Incluye como mínimo 4 casos para el programa 1 (presente, ausente, desordenada,
objetivo no entero), 3 para el programa 2 (presente, ausente, solapado) y 2 para
el programa 3 (tabla correcta e idempotencia). Un estado 0 solo demuestra éxito
operativo; compara también los números de comparaciones y el contenido de la
tabla.

## 8. README e historial

`notas/README.md` debe indicar:

- sistema y versión de Bash;
- versión del corpus y resultado de su manifiesto SHA-256;
- directorio desde el que se ejecutan los scripts;
- uso y ejemplo de cada script;
- cómo se cuentan las comparaciones en cada programa;
- interpretación de O(n) frente a O(log n), de O(n·m) y de O(n²);
- supuestos, fallos conocidos y un límite de tus scripts;
- declaración de uso de IA.

Al terminar la sesión interactiva:

```bash
history -a
history > notas/history.txt
```

El historial es evidencia auxiliar: puede incluir pruebas u omitir otras
sesiones. El README y los scripts constituyen el procedimiento reproducible.

## 9. Empaquetar e inspeccionar

Desde el directorio padre de tu proyecto:

```bash
tar -czf TC03_apellidos_nombre.tar.gz TC03_apellidos_nombre/
tar -tzf TC03_apellidos_nombre.tar.gz | head -n 40
sha256sum TC03_apellidos_nombre.tar.gz
```

Comprueba que no se incluyan contraseñas, rutas absolutas, archivos ajenos ni
resultados innecesariamente grandes. En Colab descarga el `tar.gz` y su checksum
antes de cerrar la sesión.

## Paridad entre vías

| Comprobación | Linux local | Google Colab | Criterio común |
|---|---|---|---|
| paquete y datos | archivo 0.1.0 y manifiesto | el mismo archivo descargado de GitHub | checksum idéntico |
| prueba rápida | `smoke_test.sh` | la misma orden en `%%bash` | `TC03_SMOKE_TEST_OK` |
| proyecto | `preparar_practica.sh` | el mismo script en `/content` | mismos nombres y ficheros de corpus |
| scripts | ficheros `.sh` locales | ficheros `.sh` creados con `%%writefile` | mismo contrato y números del oráculo |
| evidencia | `tar.gz` generado localmente | `tar.gz` descargado antes de cerrar | misma estructura y entrega en Campus |

Las rutas absolutas y versiones pueden variar. Colab abre una Shell nueva por
celda y su disco es temporal; esas diferencias no cambian la evaluación.

## 10. Lista final

- [ ] El setup está registrado y sé en qué Shell estoy.
- [ ] Las entradas originales no se han modificado.
- [ ] Los tres scripts pasan `bash -n` y son ejecutables.
- [ ] Las variables que contienen rutas están entrecomilladas.
- [ ] `buscar.sh` cuenta bien y rechaza lista desordenada y objetivo no entero.
- [ ] `motivo.sh` cuenta ocurrencias solapadas y comparaciones de caracteres.
- [ ] `escalado.sh` es idempotente y su columna cuadrática crece como `n·(n−1)/2`.
- [ ] Distingo O(n), O(log n), O(n·m) y O(n²) con mis propios resultados.
- [ ] `verificar_entrega.sh` termina con `TC03_SUBMISSION_TESTS_OK`.
- [ ] `pruebas.tsv` compara números y contenido, no solo estado de salida.
- [ ] El README permite repetir la práctica desde la raíz del proyecto.
- [ ] He inspeccionado el contenido del `tar.gz` antes de entregarlo.
