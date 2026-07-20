# Práctica individual TC01-S01: entorno, rutas y navegación segura

**Versión:** 0.1.0  
**Modalidad:** individual  
**Duración estimada:** 45 minutos dentro de la sesión S01  
**Vías equivalentes:** A, Linux local; B, Google Colab

## Contrato

- **Pregunta:** ¿puedes crear, recorrer y verificar un espacio de trabajo sin
  perder la referencia del directorio desde el que actúas?
- **Producto individual:** `TC01-S01_evidencia.md` y `smoke_test.tsv`.
- **Criterio de éxito:** la prueba rápida termina con
  `TC01_SMOKE_TEST_OK`, el espacio solicitado contiene los ficheros esperados y
  la explicación distingue terminal, Shell, ruta absoluta y ruta relativa.
- **Entrega:** los dos ficheros se suben al Campus Virtual. Ni GitHub ni Colab
  reciben la entrega.
- **IA:** no se utiliza en la predicción, la ejecución, la interpretación ni la
  defensa. Declara cualquier uso incidental en la plantilla de evidencia.

El resultado y los criterios son idénticos en ambas vías. Elige una sola:

- **Vía A:** un ordenador con GNU/Linux y Bash 4 o posterior.
- **Vía B:** Google Colab, cuando no dispongas de Linux local.

Windows y macOS no forman parte del soporte local directo de esta práctica. En
esos sistemas utiliza la vía B. No instales máquinas virtuales para completar
esta actividad.

## Datos y procedencia

| Recurso | Procedencia | Integridad | Uso |
|---|---|---|---|
| `datos/mini.fasta` | secuencias sintéticas creadas por el docente, CC0-1.0 | `datos/SHA256SUMS` | objeto de navegación, copia e inspección; no se interpreta biológicamente |

La prueba rápida comprueba el checksum antes de utilizar el fichero.

## Vía A: Linux local

1. Descarga o clona el paquete de la práctica.
2. Abre una terminal dentro de la carpeta `TC01-S01`.
3. Ejecuta:

```bash
chmod +x src/smoke_test.sh
./src/smoke_test.sh --report resultados/smoke_test.tsv
```

4. Comprueba que la última línea es `TC01_SMOKE_TEST_OK`.
5. Conserva `resultados/smoke_test.tsv` para la entrega.

## Vía B: Google Colab

Abre una copia individual del cuaderno enlazado desde el Campus Virtual o usa
el [cuaderno de desarrollo de TC01-S01](https://colab.research.google.com/github/Asn4code/pid_2026/blob/desarrollo/materiales/tecnicas-computacionales-biologia/TC01-S01/notebooks/TC01-S01_colab.ipynb).

1. Selecciona **Archivo > Guardar una copia en Drive**.
2. Ejecuta las celdas en orden. Las órdenes Bash aparecen en celdas `%%bash`.
3. No introduzcas datos personales, contraseñas ni información sensible.
4. Descarga los dos ficheros de evidencia antes de terminar: la máquina virtual
   de Colab es temporal.

En Colab, cada celda Bash inicia una Shell nueva. Por ello, `cd` y las órdenes
que dependan de él deben estar en la misma celda. Esta diferencia operativa no
cambia la actividad ni la evaluación.

## Actividad

### 1. Predicción individual

Sin ejecutar órdenes, dibuja o escribe el árbol que esperas obtener:

```text
TCB/
└── TC01-S01/
    ├── datos/
    ├── notas/
    └── resultados/
```

Predice también qué ruta mostrará `pwd` dentro de `datos` y qué ruta relativa
permitirá llegar desde `datos` hasta `notas`.

### 2. Construcción y navegación

Desde tu directorio personal en Linux, o desde `/content` en Colab:

1. crea el árbol previsto con `mkdir`;
2. copia `mini.fasta` a la carpeta `datos` con `cp`;
3. entra en cada directorio con `cd` y comprueba la posición con `pwd`;
4. crea `notas/setup_ok.txt` con `touch`;
5. copia ese fichero a `resultados` y cambia el nombre de la copia a
   `entorno_comprobado.txt` con `mv`;
6. inspecciona el FASTA con `file`, `head` y `wc` sin modificarlo;
7. usa `ls -l` para comprobar el resultado final.

No uses `rm` en esta práctica.

### 3. Auditoría

Parte desde `TCB/TC01-S01/datos` y considera esta orden:

```bash
cp mini.fasta resultados/copia.fasta
```

Antes de ejecutarla, explica por qué falla. Escribe una corrección mediante una
ruta relativa y otra mediante una ruta absoluta. Ejecuta solo una de las dos y
comprueba el resultado.

### 4. Evidencia

Completa `entrega/plantilla_evidencia.md` sin pegar una captura como sustituto
de la explicación. La evidencia debe incluir:

- vía A o B y salida de `uname -s`, `bash --version` y `pwd`;
- predicción inicial y contraste con el resultado;
- árbol o listado final;
- ruta absoluta y relativa al mismo fichero;
- diagnóstico del error preparado;
- diferencia entre terminal y Shell;
- declaración de uso de IA.

## Pruebas y fallos conocidos

- **Prueba rápida:** `./src/smoke_test.sh --report resultados/smoke_test.tsv`.
- **Resultado esperado:** salida final `TC01_SMOKE_TEST_OK` y un TSV cuyo campo
  `status` vale `OK`.
- **Tolerancia:** las rutas, versión de Bash y versión del núcleo variarán; el
  checksum del dato debe ser idéntico.
- **`Permission denied`:** ejecuta `chmod +x src/smoke_test.sh` o
  `bash src/smoke_test.sh ...`.
- **`No such file or directory`:** ejecuta `pwd` y `ls` antes de corregir la
  ruta; no repitas la orden a ciegas.
- **Colab se reinició:** vuelve a ejecutar las celdas desde el principio y
  descarga el resultado al acabar.

## Lista de comprobación

- [ ] He realizado la actividad individualmente.
- [ ] La prueba rápida termina con `TC01_SMOKE_TEST_OK`.
- [ ] Puedo justificar las dos rutas, no solo mostrarlas.
- [ ] Los dos ficheros de entrega se abren y no contienen secretos.
- [ ] He subido la entrega al Campus Virtual.

