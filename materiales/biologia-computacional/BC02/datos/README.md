# Datos de BC02 — Bioquímica esencial como modelo computable

## Contenido

- `mini.tsv`: tabla pequeña (7 aminoácidos) con nombre, abreviatura, código, masa, pI e hidrofobicidad. Útil para pruebas rápidas de tabulación y ordenación.
- `caso_s02.tsv`: caso sobre representaciones alternativas de aminoácidos (nombre, 3 letras, 1 letra, solo cadena lateral, solo masa) y qué información se pierde en cada una.
- `corpus/file_aminoacidos_20.tsv`: tabla completa de los 20 aminoácidos con clasificación y descripción fisicoquímica.
- `corpus/file_enlace_peptidico.md`: referencia del enlace peptídico, péptidos/proteínas y cálculo de masa aproximada.

## Licencia

Datos sintéticos creados para fines docentes. Licencia: CC0-1.0
Autor: Álvaro Serrano Navarro (docente, Universidad Nebrija)

No son datos reales de experimentos o pacientes.

## Verificación

    cd datos && sha256sum -c SHA256SUMS && sha256sum -c MANIFEST.sha256

Todos los archivos deben mostrar OK.
