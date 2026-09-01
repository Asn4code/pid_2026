# MEMORIA Y MANIFIESTO DE ENTREGABLE · VERSIÓN 2.2
**Proyecto de Innovación Docente (PID 2025–2026)**
**Asignatura:** Técnicas Computacionales en Biología
**Fecha de Congelación:** 2026-09-01 14:06 CEST
**Identificador de Versión:** 2.2 (Ilustrada, Algorítmica y Práctica)

---

## 1. Alcance y Contenido del Entregable

Este paquete reúne la totalidad de los materiales generados y validados para la asignatura *Técnicas Computacionales en Biología*:

1. 📖 **Libro de Texto Unificado:** `book_v2.2_completo.pdf` (215 páginas, compilación limpia en LaTeX con bibliografía única de 30 referencias).
2. 📄 **10 Capítulos Teóricos Individuales:** `TC01` a `TC10` en formato PDF independiente (`capitulos_pdf/`).
3. 📊 **14 Figuras Conceptuales Vectoriales:** Diagramas en PDF y PNG adaptados de las diapositivas de clase (`figuras/`).
4. 💻 **10 Kits de Laboratorio Autónomos:** Paquetes `kit_TC01.tar.gz` a `kit_TC10.tar.gz` con datos deterministas ($SEED=42$) y verificador `check_practice_delivery.sh` (emitiendo calificación perfecta `DELIVERY_OK`).
5. 🌐 **Portal Web Desplegado en GitHub Pages:** [https://asn4code.github.io/pid_2026/](https://asn4code.github.io/pid_2026/) con pestañas por tema, control dinámico de versiones (`config_capitulos.json`) y avisos de entrega exclusiva en Campus Virtual.
6. ⚖️ **Registro de Decisiones Arquitectónicas y de Innovación:** ADR-001 a ADR-007 y `FIX_LOG.md` (FIX-001 a FIX-023).

---

## 2. Inventario de Archivos del Snapshot (`artifacts/2026-09-01_1406`)

| Categoría | Elementos | Descripción |
| :--- | :---: | :--- |
| **Manual Completo** | 1 archivo | `book_v2.2_completo.pdf` (215 páginas) |
| **Capítulos Individuales** | 10 archivos | `TC01_capitulo_v2.2.pdf` a `TC10_capitulo_v2.2.pdf` |
| **Kits de Prácticas** | 10 archivos | `kit_TC01.tar.gz` a `kit_TC10.tar.gz` |
| **Figuras Vectoriales** | 14 archivos | Diagramas vectoriales de todos los temas |
| **Gobernanza & ADRs** | 8 archivos | ADR-001 a ADR-007 + `FIX_LOG.md` |
| **Integridad Criptográfica** | 1 archivo | `SHA256SUMS.txt` |

---

## 3. Verificación de Integridad Inmutable

Para comprobar que ningún archivo ha sido alterado:
```bash
sha256sum -c SHA256SUMS.txt
```
