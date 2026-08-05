# Práctica individual TC01: de la terminal a un procesamiento reproducible

**Versión:** 0.3.0

**Modalidad:** individual

**Tiempo orientativo:** 30 min de preparación + 90 min de trabajo + 20 min de comprobación

**Entorno:** vía A, GNU/Linux local; vía B, Google Colab

## Contrato de la práctica

**Pregunta:** ¿puedes convertir una exploración manual de ficheros biológicos en tres scripts seguros, explicables y comprobados?

**Producto:** un único `TC01_apellidos_nombre.tar.gz` con esta estructura:

```text
TC01_apellidos_nombre/
├── datos/                 # entradas facilitadas, sin modificar
├── scripts/               # tres scripts .sh ejecutables
├── resultados/            # salidas pequeñas solicitadas
├── notas/
│   ├── README.md
│   └── history.txt
└── pruebas.tsv            # caso, resultado esperado, real y estado
```

**Criterio de éxito:** los scripts pasan la comprobación de sintaxis, manejan las entradas válidas y los fallos indicados, no sobrescriben datos, reproducen el oráculo del corpus y pueden ejecutarse siguiendo el README.

**IA:** realiza sin IA la predicción, las pruebas, la interpretación de errores y la defensa. Si se autoriza una fase de auditoría con IA, conserva la propuesta, identifica al menos un supuesto verificable y documenta cómo lo probaste; una salida de IA no sustituye la evidencia.

## Dependencias didácticas

| Elemento utilizado | Se enseña antes en el capítulo |
|---|---|
| terminal, Bash, rutas, `pwd`, `ls`, `cd`, `mkdir`, `cp` y `mv` | S01: entorno, modelo mental, sistema de archivos y navegación |
| `head`, `tail`, `wc`, flujos, tuberías y redirecciones | S01: inspección; S02: flujos y composición |
| `grep -E`, anclas, clases, cuantificadores y casos positivos/negativos | S02: búsqueda y expresiones regulares |
| `cut`, `sort`, `uniq` y `tr` | S02: utilidades de texto y sus precondiciones |
| shebang, argumentos, comillas, arrays, globbing, bucles y condicionales | S03: de órdenes interactivas a scripts |
| `bash -n`, permisos, estados, `tar` y checksum | S03: validación, trazabilidad y entrega |

La práctica no exige `sed`, `awk`, `find`, `xargs` ni procesamiento FASTA
avanzado; esos contenidos pertenecen a módulos posteriores.

## 1. Preparar y verificar el entorno

Requisitos comunes: 1 GB de RAM disponible, menos de 1 MB de disco para los
datos, acceso al paquete versionado y ninguna GPU. Linux local requiere Bash 4
o posterior y utilidades GNU. La vía Colab requiere una sesión autorizada por
el estudiante, pero no recibe la entrega.

Documentación de referencia: [línea de comandos en
Ubuntu](https://documentation.ubuntu.com/desktop/en/latest/tutorial/the-linux-command-line-for-beginners/)
y [preguntas frecuentes de Google
Colab](https://research.google.com/colaboratory/faq.html). La vía Linux se
comprobó el 20-07-2026 con Bash 5.1.8; el informe registra la versión concreta
de cada ejecución.

Elige una sola vía. Si tienes GNU/Linux, trabaja en una terminal local con el
paquete enlazado desde el Campus. Si utilizas Windows o macOS, abre una copia
individual del [cuaderno Colab de
TC01](https://colab.research.google.com/github/Asn4code/pid_2026/blob/desarrollo/materiales/tecnicas-computacionales-biologia/TC01/notebooks/TC01_colab.ipynb).

Las dos vías utilizan los mismos datos y criterios. En Colab, cada celda
`%%bash` abre una Shell nueva: mantén `cd` y las órdenes dependientes en la
misma celda y descarga los resultados antes de terminar la sesión.

Si has descargado el archivo de inicio en Linux, verifica y extrae desde la
carpeta que contiene ambos ficheros:

```bash
sha256sum -c SHA256SUMS
tar -xzf TC01_starter_v0.3.0.tar.gz
cd TC01-starter
```

Ejecuta primero la prueba rápida del paquete:

```bash
chmod +x src/smoke_test.sh
./src/smoke_test.sh --report resultados/smoke_test.tsv
```

Debe terminar con `TC01_SMOKE_TEST_OK`. Después crea tu proyecto sin modificar
el paquete original:

```bash
./src/preparar_practica.sh ../TC01_apellidos_nombre
cd ../TC01_apellidos_nombre
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
| `No such file or directory` | `pwd` y `ls` sobre cada componente | volver a la raíz de `TC01-starter`; no adivinar rutas |
| falla el checksum | repetir la descarga sin editar el archivo | no continuar con datos o paquete alterados |
| Colab perdió los ficheros | comprobar `/content` | ejecutar de nuevo la sección de descarga; el cuaderno conserva un proyecto existente |
| Colab no está disponible | registrar el incidente en el Campus | reprogramar la ejecución en Linux sin penalización |

## 2. Preparar el espacio de trabajo

1. Crea el árbol del contrato dentro de tu directorio personal.
2. Comprueba que `preparar_practica.sh` ha copiado el corpus a `datos/` y conserva intacto el paquete recibido.
3. Desde la raíz de tu proyecto, inspecciona una muestra de cada extensión con `file`, `wc -l`, `head` y `tail`.
4. Anota una predicción del número de FASTA, TXT y LOG antes de automatizar el conteo.
5. No uses `rm` en esta práctica.

El corpus docente sintético 0.1.0 contiene 21 ficheros regulares: 11 FASTA, 6 TXT y 4 LOG. Incluye nombres con espacios. Si el docente entrega una variante, prevalece el manifiesto que la acompaña y debes calcular los resultados, no copiarlos de este texto.

## 3. Caso mínimo antes del corpus

Inspecciona primero `datos/caso_s02.fasta`, un ejemplo conocido. Después crea en `datos/pruebas/` otro FASTA individual de dos registros. Debe contener una secuencia en dos líneas, al menos tres apariciones de `ATG` repartidas en dos líneas y un símbolo ambiguo `N`. En `pruebas.tsv`, registra:

- líneas totales;
- registros esperados y observados mediante cabeceras `^>`;
- líneas que contienen `ATG`;
- coincidencias no solapadas de `ATG`;
- símbolos observados en las líneas de secuencia.

Construye cada tubería de izquierda a derecha y conserva una prueba positiva y otra negativa para la regex principal.

## 4. Programa 1: extremos de todos los FASTA

Escribe `scripts/extremos_fasta.sh`. Debe:

1. aceptar opcionalmente un directorio; por defecto usar `datos/`;
2. seleccionar ficheros que terminen en `.fasta` mediante globbing, no mediante la salida de `ls`;
3. mostrar una etiqueta con el nombre y después la primera y última línea;
4. conservar nombres con espacios como un solo argumento;
5. terminar con diagnóstico en stderr y estado distinto de cero si no existe el directorio o no hay coincidencias.

Prueba directorio válido, directorio vacío y directorio inexistente. En el corpus docente deben procesarse 11 FASTA, incluido `muestra con espacio.fasta`.

## 5. Programa 2: inventario y resumen

Escribe `scripts/inventario.sh`. Debe:

1. aceptar el directorio de entrada como argumento;
2. contar solo ficheros regulares cuyo nombre termina en `.txt`;
3. escribir un nombre por línea de todos los ficheros regulares en `resultados/file_list.txt`;
4. ordenar de forma reproducible el inventario;
5. escribir sus diez primeras líneas en `resultados/summary.txt`;
6. regenerar los resultados sin duplicar líneas al repetir la ejecución;
7. fallar con un mensaje claro si la entrada no es un directorio.

En el corpus docente se esperan 6 TXT, 21 líneas en `file_list.txt` y 10 en `summary.txt`. Explica en el README por qué `ls | wc -l` no satisface el contrato.

## 6. Programa 3: contenido completo o extremos

Escribe `scripts/resumir_fichero.sh`. Debe recibir exactamente un fichero legible:

- con 20 líneas o menos, muestra el contenido completo;
- con más de 20, envía un aviso y muestra las 10 primeras y 10 últimas;
- sin argumento, con argumentos de más o con fichero ausente, explica el uso por stderr y termina con estado distinto de cero.

Prueba explícitamente 19, 20 y 21 líneas, además del fichero ausente. En el corpus docente, `file_4.fasta` y `file_5.fasta` permiten probar 19 y 21; construye tú el caso de 20.

## 7. Validación obligatoria

Antes de empaquetar:

```bash
bash -n scripts/extremos_fasta.sh
bash -n scripts/inventario.sh
bash -n scripts/resumir_fichero.sh
chmod u+x scripts/*.sh
bash /ruta/al/paquete/TC01-starter/src/verificar_entrega.sh .
```

En Colab, la ruta del último comando es
`/content/TC01-starter/src/verificar_entrega.sh`. La prueba automática comprueba
el contrato técnico, pero no sustituye `pruebas.tsv`, la interpretación ni la
defensa individual.

Completa `pruebas.tsv` con las columnas:

```text
script	caso	esperado	real	estado_salida	OK_NO
```

Incluye como mínimo 3 casos para el programa 1, 2 para el programa 2, 4 para el programa 3 y las comprobaciones del FASTA mínimo. Un estado 0 solo demuestra éxito operativo; compara también contenido, número de líneas y estructura.

## 8. README e historial

`notas/README.md` debe indicar:

- sistema y versión de Bash;
- versión del corpus y resultado de su manifiesto SHA-256;
- directorio desde el que se ejecutan los scripts;
- uso y ejemplo de cada script;
- supuestos sobre nombres, formato y delimitadores;
- resultados del oráculo y cualquier diferencia razonada;
- fallos conocidos y límite de los pipelines sobre FASTA;
- declaración de uso de IA.

Al terminar la sesión interactiva:

```bash
history -a
history > notas/history.txt
```

El historial es evidencia auxiliar: puede incluir pruebas u omitir otras sesiones. El README y los scripts constituyen el procedimiento reproducible.

## 9. Empaquetar e inspeccionar

Desde el directorio padre de tu proyecto:

```bash
tar -czf TC01_apellidos_nombre.tar.gz TC01_apellidos_nombre/
tar -tzf TC01_apellidos_nombre.tar.gz | head -n 40
sha256sum TC01_apellidos_nombre.tar.gz
```

Comprueba que no se incluyan contraseñas, rutas absolutas, archivos ajenos ni resultados innecesariamente grandes. En Colab descarga el `tar.gz` y su checksum antes de cerrar la sesión.

## Paridad entre vías

| Comprobación | Linux local | Google Colab | Criterio común |
|---|---|---|---|
| paquete y datos | archivo 0.3.0 y manifiesto | el mismo archivo descargado de GitHub | checksum idéntico |
| prueba rápida | `smoke_test.sh` | la misma orden en `%%bash` | `TC01_SMOKE_TEST_OK` |
| proyecto | `preparar_practica.sh` | el mismo script en `/content` | mismos nombres y 21 ficheros de corpus |
| scripts | ficheros `.sh` locales | ficheros `.sh` creados con `%%writefile` | mismo contrato y batería de caja negra |
| evidencia | `tar.gz` generado localmente | `tar.gz` descargado antes de cerrar | misma estructura y entrega en Campus |

Las rutas absolutas y versiones pueden variar. Colab abre una Shell nueva por
celda y su disco es temporal; esas diferencias no cambian la evaluación.

## 10. Lista final

- [ ] El setup está registrado y sé en qué Shell estoy.
- [ ] Las entradas originales no se han modificado.
- [ ] Los tres scripts pasan `bash -n` y son ejecutables.
- [ ] Las variables que contienen rutas están entrecomilladas.
- [ ] Se prueban cero entradas, entrada inválida y fronteras 19/20/21.
- [ ] Distingo líneas, coincidencias y registros en el FASTA mínimo.
- [ ] Repetir el inventario no duplica resultados.
- [ ] `verificar_entrega.sh` termina con `TC01_SUBMISSION_TESTS_OK`.
- [ ] `pruebas.tsv` compara esperado y real, no solo estado de salida.
- [ ] El README permite repetir la práctica desde la raíz del proyecto.
- [ ] He inspeccionado el contenido del `tar.gz` antes de entregarlo.
