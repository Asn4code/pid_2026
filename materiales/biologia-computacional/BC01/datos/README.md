# Datos docentes de BC-CH01

Los dos ficheros de esta carpeta son sintéticos. Los escribió Álvaro Serrano
Navarro para este capítulo y se redistribuyen con licencia CC0-1.0 y manifiesto
propio. No proceden de ningún organismo ni de ninguna base de datos pública: no
representan secuencias reales.

| Fichero | Contenido | Para qué |
|---|---|---|
| `bc01_secuencias.fasta` | cuatro registros FASTA, uno rico en GC, uno rico en AT, uno mosaico y uno de doce bases | perfiles de contenido GC y cálculo a mano |
| `bc01_lecturas_crudas.txt` | cuatro lecturas sin normalizar: minúsculas, una `N`, espacios sobrantes y una `U` | poner a prueba la guarda de dominio |

El fichero de lecturas crudas es deliberadamente sucio. Tres de las cuatro
lecturas deben ser rechazadas o normalizadas por su módulo, y decidir cuál es
cada caso forma parte del trabajo: una `N` no es lo mismo que un espacio
sobrante, y una `U` en un fichero que dice contener ADN es un aviso de que
alguien mezcló ARN con ADN.

Para comprobar que no ha modificado nada, desde esta carpeta:

```bash
sha256sum -c manifest.sha256
```
