# Datos docentes de TC04 (estructuras lineales)

Todos los ficheros de esta carpeta son sintéticos y han sido creados por
Álvaro Serrano Navarro para TC04. Se dedican al dominio público mediante
CC0-1.0. No representan muestras ni secuencias biológicas reales.

## Recursos

| Recurso | Versión | Finalidad |
|---|---|---|
| `mini.txt` | 0.1.0 | estructura punto-paréntesis mínima para la comprobación rápida de S08 |
| `caso.fasta` | 0.1.0 | secuencia conocida para ventanas deslizantes (array) |
| `caso_estructura.txt` | 0.1.0 | estructura equilibrada conocida para la pila |
| `caso_ids.txt` | 0.1.0 | lista de identificadores para la cola |
| `corpus/` | 0.1.0 | práctica integradora S08-S09: secuencia, estructuras y lecturas |

La notación punto-paréntesis representa la estructura secundaria de un ARN: `(` y
`)` marcan bases emparejadas y `.` bases libres. `estructura_ok.txt` está
equilibrada (profundidad 3); `estructura_extra_cierre.txt` tiene un cierre de más
en la posición 5; `estructura_extra_apertura.txt` deja una apertura sin cerrar.

```bash
sha256sum -c SHA256SUMS
sha256sum -c MANIFEST.sha256
```
