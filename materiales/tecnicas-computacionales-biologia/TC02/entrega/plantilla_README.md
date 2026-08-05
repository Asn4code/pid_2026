# README de la entrega TC02

Completa este fichero desde la raíz de tu proyecto. Debe permitir repetir la
práctica sin ayuda adicional.

## Entorno

- Sistema (`uname -s`):
- Versión de Bash (primera línea de `bash --version`):
- Versiones de `sed` y `awk` (`sed --version`, `awk --version`):
- Directorio desde el que se ejecutan los scripts:

## Datos

- Versión del corpus: 0.1.0
- Resultado de `sha256sum -c MANIFEST.sha256`:

## Programa 1: `transcribir.sh`

- Uso y ejemplo:
- Por qué `/^>/!` evita transcribir las cabeceras:
- Diferencia entre `s/T/U/` y `s/T/U/g`:
- Por qué se prueba `sed` sin `-i` antes de editar en el sitio:

## Programa 2: `longitudes.sh`

- Uso y ejemplo:
- Cómo acumula `awk` la longitud de una secuencia repartida en varias líneas:
- Por qué `wc -l` o un `grep` por línea no sirven para medir una secuencia:

## Programa 3: `gc.sh`

- Uso y ejemplo:
- Cómo cuentas G y C con `gsub` sin alterar la secuencia original:
- Contenido GC observado para un fichero del corpus:

## Supuestos y límites

- Supuestos sobre el formato FASTA de las entradas:
- Un dialecto de regex distinto entre `grep`, `sed` y `awk` que hayas tenido en cuenta:
- Un fallo conocido de tus scripts:

## Autoría e IA

- Confirmo que los scripts, las pruebas y la evidencia son individuales: sí / no
- Uso de IA: ninguno / uso declarado
- Herramienta, consulta, fragmento afectado y forma de verificación, si procede:

[completar o escribir «no procede»]
