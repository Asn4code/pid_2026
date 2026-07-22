# Práctica individual TC02: transformar secuencias con sed y awk

**Versión:** 0.1.0

**Modalidad:** individual

**Tiempo orientativo:** 30 min de preparación + 90 min de trabajo + 20 min de comprobación

**Entorno:** vía A, GNU/Linux local; vía B, Google Colab

## Contrato de la práctica

**Pregunta:** ¿puedes convertir la transformación manual de ficheros FASTA en tres
scripts con `sed` y `awk` que sean seguros, explicables y comprobados?

**Producto:** un único `TC02_apellidos_nombre.tar.gz` con esta estructura:

```text
TC02_apellidos_nombre/
├── datos/                 # entradas facilitadas, sin modificar
├── scripts/               # tres scripts .sh ejecutables
├── resultados/            # salidas pequeñas solicitadas
├── notas/
│   ├── README.md
│   └── history.txt
└── pruebas.tsv            # caso, resultado esperado, real y estado
```

**Criterio de éxito:** los scripts pasan la comprobación de sintaxis, transforman
solo lo que deben (sin tocar las cabeceras), manejan FASTA multilínea, no
sobrescriben datos, reproducen el oráculo del corpus y pueden ejecutarse siguiendo
el README.

**IA:** realiza sin IA la predicción, las pruebas, la interpretación de errores y
la defensa. Con `sed` y `awk`, una salida de IA que «parece» correcta puede fallar
en silencio; audítala en modo lectura y documenta cómo la probaste.

## Antes de empezar: lectura del capítulo

Esta práctica da por leído el capítulo de TC02. Necesitas manejar sin consultarlo:

- variables entrecomilladas y sustitución de orden `$(...)`;
- bucles `for` sobre ficheros y `while read -r` línea a línea;
- `sed`: sustitución `s///g`, direcciones (`/^>/`, `/^>/!`), `-n`/`p`, grupos de captura y el peligro de `sed -i`;
- `awk`: campos `$1`/`$NF`, `NR`/`NF`, `-F`, bloques `BEGIN`/`END` y acumulación por registro multilínea;
- por qué `grep`, `sed` y `awk` usan dialectos de regex parecidos pero no idénticos.

## Dependencias didácticas

| Elemento utilizado | Se enseña antes en el capítulo |
|---|---|
| variables, comillas y `$(...)` | S04: variables, comillas y sustitución de orden |
| bucles `for` y `while read -r` | S04: bucles |
| `grep -w`, `-A`, `-f`, `-E` | S04: grep, segunda vuelta |
| `sed`: `s///g`, direcciones, `-n`, grupos, `-i` | S04: sed, el editor de flujo |
| `awk`: campos, `NR`/`NF`, `-F`, `BEGIN`/`END` | S05: awk, campos y registros |
| longitud y GC de FASTA multilínea | S05: awk sobre secuencias |

## 1. Preparar y verificar el entorno

Requisitos comunes: Bash 4 o posterior, `sed`, `awk`, `grep` y utilidades GNU;
menos de 1 MB de disco y ninguna GPU. Elige una sola vía. Si tienes GNU/Linux,
trabaja en una terminal local con el paquete enlazado desde el Campus. Si utilizas
Windows o macOS, abre una copia individual del [cuaderno Colab de
TC02](https://colab.research.google.com/github/Asn4code/pid_2026/blob/desarrollo/materiales/tecnicas-computacionales-biologia/TC02/notebooks/TC02_colab.ipynb).

Documentación de referencia: [línea de comandos en
Ubuntu](https://documentation.ubuntu.com/desktop/en/latest/tutorial/the-linux-command-line-for-beginners/)
y [preguntas frecuentes de Google
Colab](https://research.google.com/colaboratory/faq.html). La vía Linux se
comprobó el 20-07-2026 con Bash 5.1.8.

Si has descargado el archivo de inicio en Linux, verifica y extrae:

```bash
sha256sum -c SHA256SUMS
tar -xzf TC02_starter_v0.1.0.tar.gz
cd TC02-starter
chmod +x src/smoke_test.sh
./src/smoke_test.sh --report resultados/smoke_test.tsv
```

Debe terminar con `TC02_SMOKE_TEST_OK`. Después crea tu proyecto sin modificar el
paquete original:

```bash
./src/preparar_practica.sh ../TC02_apellidos_nombre
cd ../TC02_apellidos_nombre
```

### Diagnóstico de setup

| Síntoma | Comprobación | Solución |
|---|---|---|
| `Permission denied` al iniciar un script | `ls -l src/` | `chmod +x src/*.sh` o ejecutarlo con `bash` |
| falla el checksum | repetir la descarga sin editar el archivo | no continuar con datos alterados |
| `sed -i` corrompió un dato | trabajar sobre copias; no usar `-i` en la práctica | reextraer el paquete y no editar en el sitio |
| un `awk` da longitudes raras | procesar por registro, no por línea | acumular hasta la siguiente cabecera |
| Colab perdió los ficheros | comprobar `/content` | ejecutar de nuevo la sección de descarga |

## 2. Caso mínimo antes del corpus

Antes de automatizar, razona a mano sobre `datos/caso.fasta` (dos registros
multilínea). Predice: cuántas `T` hay en las líneas de secuencia (serán las
sustituciones de la transcripción), la longitud de cada registro y su contenido
GC. Escribe tu predicción en `pruebas.tsv` antes de ejecutar nada. No uses `sed
-i` en ningún momento de la práctica.

## 3. Programa 1: transcripción con sed

Escribe `scripts/transcribir.sh`. Debe recibir exactamente `FICHERO` y:

1. rechazar con estado distinto de cero un fichero ausente o ilegible;
2. transcribir ADN a ARN (`T`→`U`) **solo en las líneas de secuencia**, con `sed '/^>/!s/T/U/g'`;
3. imprimir el FASTA transcrito por salida estándar, conservando las cabeceras intactas;
4. informar del número de sustituciones por salida de error.

En `caso.fasta` deben transcribirse **8** `T` y no debe quedar ninguna `T` en las
líneas de secuencia; las cabeceras `>caso_uno` y `>caso_dos` no cambian.

## 4. Programa 2: longitudes con awk

Escribe `scripts/longitudes.sh`. Debe recibir `FICHERO` y, con `awk`, imprimir una
línea `id<TAB>longitud` por registro, **acumulando** las secuencias repartidas en
varias líneas. En el corpus, `adn_3.fasta` (cuatro líneas) mide **34**, y cada
registro de `caso.fasta` mide **16**. Explica por qué `wc -l` no sirve.

## 5. Programa 3: contenido GC con awk

Escribe `scripts/gc.sh`. Debe recibir `FICHERO` y, con `awk`, imprimir por registro
`id<TAB>gc<TAB>longitud<TAB>porcentaje` (una cifra decimal), contando G y C con
`gsub` sobre una copia de la línea. En el corpus, `adn_3.fasta` da `32 34 94.1` y
`adn_2.fasta` da `0 20 0.0`.

## 6. Validación obligatoria

```bash
bash -n scripts/transcribir.sh
bash -n scripts/longitudes.sh
bash -n scripts/gc.sh
chmod u+x scripts/*.sh
bash /ruta/al/paquete/TC02-starter/src/verificar_entrega.sh .
```

En Colab, la ruta del último comando es
`/content/TC02-starter/src/verificar_entrega.sh`. La prueba automática comprueba el
contrato y los números del oráculo, pero no sustituye `pruebas.tsv`, la
interpretación ni la defensa. Completa `pruebas.tsv` con las columnas:

```text
script	caso	esperado	real	estado_salida	OK_NO
```

## 7. README, historial y empaquetado

`notas/README.md` debe indicar entorno, versiones de `sed` y `awk`, uso de cada
script, diferencia entre dialectos y por qué se prueba `sed` sin `-i`. Al terminar:

```bash
history -a
history > notas/history.txt
cd ..
tar -czf TC02_apellidos_nombre.tar.gz TC02_apellidos_nombre/
tar -tzf TC02_apellidos_nombre.tar.gz | head -n 40
sha256sum TC02_apellidos_nombre.tar.gz
```

En Colab descarga el `tar.gz` y su checksum antes de cerrar la sesión.

## 8. Lista final

- [ ] Los tres scripts pasan `bash -n` y son ejecutables.
- [ ] Las variables que contienen rutas están entrecomilladas.
- [ ] La transcripción usa `/^>/!` y no toca las cabeceras.
- [ ] Distingo `s/T/U/` de `s/T/U/g`.
- [ ] Mido longitud y GC acumulando por registro multilínea.
- [ ] No he usado `sed -i` en ningún momento.
- [ ] `verificar_entrega.sh` termina con `TC02_SUBMISSION_TESTS_OK`.
- [ ] `pruebas.tsv` compara salida esperada y real.
- [ ] He inspeccionado el contenido del `tar.gz` antes de entregarlo.
