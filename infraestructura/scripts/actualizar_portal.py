#!/usr/bin/env python3
"""
tools/actualizar_portal.py
--------------------------
Regenera las páginas markdown del portal docente leyendo:
- docs/assets/topics_data.json (datos de los 10 temas y pseudocódigos)
- config_capitulos.json (configuración de descarga y versiones de capítulos)
"""

import os, json

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TOPICS_FILE = os.path.join(BASE_DIR, "docs/assets/topics_data.json")
CONFIG_FILE = os.path.join(BASE_DIR, "config_capitulos.json")
TC_DIR = os.path.join(BASE_DIR, "docs/tecnicas-computacionales-biologia")

with open(TOPICS_FILE, "r", encoding="utf-8") as f:
    topics = json.load(f)

with open(CONFIG_FILE, "r", encoding="utf-8") as f:
    cap_config = json.load(f)

os.makedirs(TC_DIR, exist_ok=True)

for t in topics:
    num_str = t["num"]
    key = f"TC{num_str}"
    cfg = cap_config.get(key, {
        "enabled": True,
        "active_version": "v2.2",
        "versions": {"v2.2": f"assets/capitulos/TC{num_str}_capitulo_v2.2.pdf"}
    })
    
    if cfg.get("enabled", True):
        active_ver = cfg.get("active_version", "v2.2")
        pdf_rel = f"../{cfg['versions'].get(active_ver, f'assets/capitulos/TC{num_str}_capitulo_{active_ver}.pdf')}"
        
        hist_links = []
        for ver, path in cfg.get("versions", {}).items():
            if ver != active_ver:
                hist_links.append(f'<a href="../{path}" class="md-button md-button--secondary" style="font-size:0.8em; margin-left:0.5em;" download>Versión {ver}</a>')
        hist_html = ("<p style='margin-top:0.8em; font-size:0.85em;'>Versiones alternativas disponibles: " + " ".join(hist_links) + "</p>") if hist_links else ""
        
        chapter_block = f"""
    <div style="margin: 1.5em 0;" class="admonition info">
      <p class="admonition-title">📖 Capítulo Teórico Disponible ({active_ver})</p>
      <p>Puede consultar y descargar el capítulo teórico individual en formato PDF para preparar esta sesión:</p>
      <p>
        <a href="{pdf_rel}" class="md-button md-button--primary" download>
          📥 Descargar Capítulo TC{num_str} (PDF · {active_ver})
        </a>
      </p>
      {hist_html}
    </div>
"""
    else:
        chapter_block = f"""
    <div style="margin: 1.5em 0;" class="admonition warning">
      <p class="admonition-title">🔒 Capítulo en Revisión Docente</p>
      <p>El PDF de este capítulo no está disponible para descarga pública directa en este momento. Consulte la versión oficial en el Campus Virtual.</p>
    </div>
"""

    md_filename = os.path.join(TC_DIR, f"tc{num_str}.md")
    content = f"""---
title: TC{num_str} - {t['title']}
description: {t['desc']}
---

# TC{num_str} · {t['title']}

<div class="admonition note">
<p class="admonition-title">{t['block']}</p>
<p>{t['desc']}</p>
</div>

!!! warning "Entrega Oficial en Campus Virtual"
    **Importante:** La entrega, evaluación y calificación oficial de esta práctica se realiza **exclusivamente a través del Campus Virtual**. Los kits descargables aquí son para experimentación y autoevaluación local (`check_practice_delivery.sh`).

---

=== "📖 Capítulo Teórico & Pseudocódigo"

{chapter_block}

    ### Algoritmo Estructurado y Especificación Formal

    ```text
{t['pseudocode']}
    ```

    ???+ info "Complejidad Asintótica Formal"
        **Análisis:** {t['complexity']}

=== "📊 Diagrama Vectorial"

    ### Diagrama Conceptual de Referencia

    ![{t['figure_alt']}](../assets/figures/{os.path.basename(t['figure_img'])})

    *{t['figure_caption']}*

=== "💻 Laboratorio & Descarga de Kit"

    ### {t['practice_title']}

    {t['practice_desc']}

    <div style="margin: 1.5em 0;">
      <a href="../assets/kits/{os.path.basename(t['practice_kit'])}" class="md-button md-button--primary" download>
        📥 Descargar Kit de Práctica (kit_TC{num_str}.tar.gz)
      </a>
    </div>

    #### 1. Inicialización del Espacio de Trabajo
    ```bash
    tar -xzf kit_TC{num_str}.tar.gz
    bash create_workspace.sh MiEntrega_TC{num_str}
    cd MiEntrega_TC{num_str}
    ```

    #### 2. Autoevaluación Local (DELIVERY_OK)
    ```bash
    bash check_practice_delivery.sh MiEntrega_TC{num_str}
    # Debe emitir: [DELIVERY_OK] (3.0 / 3.0 pts)
    ```

    #### 3. Empaquetado y Entrega en Campus Virtual
    Comprima su carpeta de entrega conteniendo `notas/respuestas.tsv` y súbala al Campus Virtual:
    ```bash
    tar -czf MiEntrega_TC{num_str}.tar.gz MiEntrega_TC{num_str}/
    ```

=== "⚡ Recursos Interactivos"

    ### Espacio de Experimentación y Simulación

    <div class="admonition tip">
    <p class="admonition-title">Entorno Interactivo y Datos Reproducibles</p>
    <p>Este módulo cuenta con datasets sintéticos generados de forma determinista (<code>SEED=42</code>) y scripts en streaming incluidos en el kit de práctica.</p>
    </div>

    *(Espacio reservado para widgets interactivos adicionales en HTML5 / WebAssembly / Pyodide).*

=== "📋 Rúbrica ADR-001 (30/70)"

    ### Criterios Estandarizados de Evaluación

    | Componente | Peso | Criterio de Evaluación |
    | :--- | :---: | :--- |
    | **Entrega Técnica Automatizada** | **30% (3.0 pts)** | {t['rubric_30']} |
    | **Razonamiento Conceptual & Robustez** | **70% (7.0 pts)** | {t['rubric_70']} |

    !!! note "Marco de IA Responsable"
        - **Permitido con declaración:** Lluvia de ideas, depuración de errores y explicaciones alternativas.
        - **Restringido:** Código generado para entregables (requiere traza de prompt y verificación).
        - **No permitido:** Datos sensibles, invención de fuentes o entrega de código no comprendido.

---

[Volver al Índice de Técnicas Computacionales](index.md){{ .md-button }}
"""
    with open(md_filename, "w", encoding="utf-8") as out_f:
        out_f.write(content)

print("Portal actualizado correctamente con tools/actualizar_portal.py.")
