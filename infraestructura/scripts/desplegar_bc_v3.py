#!/usr/bin/env python3
"""
desplegar_bc_v3.py
------------------
Sincroniza y despliega Biología Computacional V3.0 en el portal público MkDocs:
1. Copia y rasteriza las 42 figuras vectoriales PDF a PNG.
2. Copia los PDFs de los capítulos individuales y el libro completo.
3. Genera los kits de práctica descargables kit_BC01.tar.gz a kit_BC14.tar.gz.
4. Genera las 14 páginas Markdown en docs/biologia-computacional/bc01.md..bc14.md e index.md.
5. Actualiza config_capitulos.json.
"""

import os
import sys
import json
import shutil
import tarfile
import subprocess
from pathlib import Path

PID_ROOT = Path("/home/aserrano/Documents/pid")
REGEN_ROOT = PID_ROOT / "proyecto_innovacion/desarrollo_docente/regeneracion_libros/biologia_computacional"
DOCS_DIR = PID_ROOT / "docs"
ASSETS_DIR = DOCS_DIR / "assets"
CAPS_DIR = ASSETS_DIR / "capitulos"
FIGS_DIR = ASSETS_DIR / "figures"
KITS_DIR = ASSETS_DIR / "kits"
BC_MD_DIR = DOCS_DIR / "biologia-computacional"

TOPICS_BC = [
    {
        "id": "BC01", "num": "01",
        "title": "Dogma Central y Representación Digital",
        "block": "Bloque I: Fundamentos Biológicos y Biofísicos",
        "desc": "Flujo de información ADN -> ARN -> Proteína, código genético degenerado de 64 codones, coordenadas biológicas 1-based y hebra reversa complementaria.",
        "figure_img": "assets/figures/BC01-F01.png",
        "figure_alt": "Flujo del Dogma Central de la Biología Molecular y arquitectura génica eucariota.",
        "figure_caption": "Dogma Central: Transcripción de ADN a ARN mensajero y traducción mediante el código genético degenerado.",
        "pseudocode": "ALGORITMO: Reverse_Complement_1Based\nENTRADA: Secuencia ADN S de longitud L, Coordenadas (inicio, fin) en base 1\nSALIDA: Subcadena reversa complementaria S_rc\n\n1. Sub <- Subcadena(S, inicio, fin)\n2. Tabla_Comp <- {'A':'T', 'T':'A', 'C':'G', 'G':'C'}\n3. S_rc <- Invertir([Tabla_Comp[nt] para cada nt en Sub])\n4. Retornar S_rc",
        "complexity": "O(L) tiempo lineal, O(L) memoria auxiliar para la cadena complementaria.",
        "practice_title": "Práctica 1: Dogma Central y Coordenadas Biológicas",
        "practice_kit": "assets/kits/kit_BC01.tar.gz",
        "practice_desc": "Manipulación de secuencias de ADN/ARN, cálculo de masa molecular teórica (110 Da/aa, 330 Da/nt), transcripción y traducción in silico.",
        "rubric_30": "Ejecución correcta de practice_checks.py (1.0), cálculo exacto de coordenadas 1-based (1.0) y tipado estricto (1.0).",
        "rubric_70": "Explicación del impacto biológico de la degeneración del código (30%), gestión defensiva de bases ambiguas IUPAC (20%) e interpretación de marcos abiertos de lectura (20%)."
    },
    {
        "id": "BC02", "num": "02",
        "title": "Biofísica de Proteínas y Estructura Secundaria",
        "block": "Bloque I: Fundamentos Biológicos y Biofísicos",
        "desc": "Geometría planar del enlace peptídico, ángulos diedros (phi, psi), cooperatividad alostérica de Hill y patrones de puentes de hidrógeno en hélices alfa y láminas beta.",
        "figure_img": "assets/figures/BC02-F01.png",
        "figure_alt": "Plano rígido peptídico omega=180° y ángulos diedros phi y psi.",
        "figure_caption": "Geometría del enlace peptídico: carácter parcial de doble enlace y rotaciones diedras permitidas.",
        "pseudocode": "ALGORITMO: Hill_Allosteric_Binding\nENTRADA: Concentracion ligando [L], Constante disociacion Kd, Coeficiente Hill n_H\nSALIDA: Fraccion de saturacion Theta\n\n1. Si [L] < 0 o Kd <= 0 o n_H <= 0: Lanzar ValueError\n2. Numerador <- [L] ^ n_H\n3. Denominador <- (Kd ^ n_H) + ([L] ^ n_H)\n4. Retornar Numerador / Denominador",
        "complexity": "O(1) tiempo constante por evaluación de saturación ligando-receptor.",
        "practice_title": "Práctica 2: Propiedades Fisicoquímicas y Alosterismo",
        "practice_kit": "assets/kits/kit_BC02.tar.gz",
        "practice_desc": "Cálculo de punto isoeléctrico pI, masa monoisotópica vs promedio, y curvas de saturación cooperativa de Hill.",
        "rubric_30": "Superación de practice_checks.py (1.0), cálculo de pI con 0 errores (1.0) y modularidad (1.0).",
        "rubric_70": "Deducción de cooperatividad alostérica positiva n_H > 1 (30%), derivación de puentes H en hélices 3.6 residuos/giro (20%) y robustez numérica (20%)."
    },
    {
        "id": "BC03", "num": "03",
        "title": "Arquitectura del Genoma y Variación de Secuencia",
        "block": "Bloque I: Fundamentos Biológicos y Biofísicos",
        "desc": "Organización del genoma eucariota, nucleosomas (146 pb), islas CpG (ratio Obs/Esp > 0.6), transiciones/transversiones (Ti/Tv 2.0-2.1) y formato VCFv4.2.",
        "figure_img": "assets/figures/BC03-F01.png",
        "figure_alt": "Arquitectura del nucleosoma y empaquetamiento de la cromatina.",
        "figure_caption": "El nucleosoma: 146 pb de ADN enrolladas en 1.65 vueltas sobre el octámero de histonas H2A, H2B, H3 y H4.",
        "pseudocode": "ALGORITMO: Calculo_CpG_ObsExp_Ratio\nENTRADA: Secuencia ADN S de longitud L\nSALIDA: Ratio Obs/Esp, Porcentaje GC\n\n1. N_CpG <- Contar_Dinucleotido(S, 'CG')\n2. N_C <- Contar_Base(S, 'C'); N_G <- Contar_Base(S, 'G')\n3. Ratio <- (N_CpG * L) / (N_C * N_G)\n4. Pct_GC <- ((N_C + N_G) / L) * 100\n5. Retornar (Ratio, Pct_GC)",
        "complexity": "O(L) tiempo lineal en un solo pase sobre la secuencia.",
        "practice_title": "Práctica 3: Análisis de Islas CpG y Anotación VCF",
        "practice_kit": "assets/kits/kit_BC03.tar.gz",
        "practice_desc": "Detección algorítmica de islas CpG promotoras, ratio Ti/Tv y parsing de registros VCFv4.2 de anemia falciforme (rs334).",
        "rubric_30": "Parsing correcto de VCFv4.2 (1.0), cálculo exacto de islas CpG (1.0) y verificación automatizada (1.0).",
        "rubric_70": "Interpretación biológica del sesgo de desaminación de 5-metilcitosina (30%), diagnóstico de ratio Ti/Tv para control de calidad genómico (20%) y análisis de impacto funcional (20%)."
    },
    {
        "id": "BC04", "num": "04",
        "title": "Transcripción, Splicing y Expresión Génica",
        "block": "Bloque I: Fundamentos Biológicos y Biofísicos",
        "desc": "Ciclo de la ARN Polimerasa II, complejo PIC/CTD, splicing por transesterificación, hipótesis del bamboleo y normalización TPM invariante a 10^6.",
        "figure_img": "assets/figures/BC04-F01.png",
        "figure_alt": "Ciclo de la ARN Polimerasa II y complejo de preiniciación transcripcional.",
        "figure_caption": "Transcripción eucariota: ensamblaje del PIC, fosforilación del CTD y elongación procesiva.",
        "pseudocode": "ALGORITMO: Normalizacion_TPM_RNASeq\nENTRADA: Vector Counts C, Vector Longitudes L en kb\nSALIDA: Vector Expresion TPM\n\n1. RPK <- [C[i] / L[i] para cada gen i]\n2. Suma_RPK <- Sumatorio(RPK)\n3. Factor_Escala <- Suma_RPK / 10^6\n4. TPM <- [RPK[i] / Factor_Escala para cada gen i]\n5. Retornar TPM",
        "complexity": "O(G) donde G es el número total de genes evaluados.",
        "practice_title": "Práctica 4: Splicing y Cuantificación TPM",
        "practice_kit": "assets/kits/kit_BC04.tar.gz",
        "practice_desc": "Simulación de transesterificaciones de splicing, cuantificación de expresión en TPM y verificación de la invariancia de suma a un millón.",
        "rubric_30": "Invariancia estricta de suma sum(TPM)=10^6 (1.0), cálculo de RPK sin sesgo (1.0) y autocontrol (1.0).",
        "rubric_70": "Demostración de por qué TPM supera a RPKM/FPKM en comparativas inter-muestra (30%), análisis del balance GC3 y estabilidad del ARNm (20%) y defensa razonada (20%)."
    },
    {
        "id": "BC05", "num": "05",
        "title": "Plegamiento y Geometría Macromolecular",
        "block": "Bloque I: Fundamentos Biológicos y Biofísicos",
        "desc": "Hipótesis de Anfinsen, embudo de plegamiento, formato PDB, distancias 3D, mapas de contacto inter-Ca (8.0 A) y superposición de Kabsch por SVD.",
        "figure_img": "assets/figures/BC05-F01.png",
        "figure_alt": "Embudo de plegamiento de Anfinsen y paisaje conformacional.",
        "figure_caption": "Embudo de Anfinsen: descenso por gradiente de energía libre desde estados desnaturalizados hasta la conformación nativa mínima.",
        "pseudocode": "ALGORITMO: Superposicion_Kabsch_RMSD\nENTRADA: Coordenadas P (diana), Coordenadas Q (modelo) de N atomos centrados\nSALIDA: Matriz de Rotacion U, RMSD optimo\n\n1. Matriz_Covarianza H <- Transpuesta(P) * Q\n2. V, S, Wt <- Descomposicion_Valores_Singulares(H)\n3. d <- Determinante(V * Wt)\n4. Matriz_D <- Diagonal(1, 1, d)\n5. Matriz_Rotacion U <- V * Matriz_D * Wt\n6. Q_rot <- Q * Transpuesta(U)\n7. RMSD <- sqrt(Sumatorio(||P_i - Q_rot_i||^2) / N)\n8. Retornar (U, RMSD)",
        "complexity": "O(N) para calcular la covarianza más O(3^3) = O(1) para el SVD 3x3.",
        "practice_title": "Práctica 5: Geometría PDB y Algoritmo de Kabsch",
        "practice_kit": "assets/kits/kit_BC05.tar.gz",
        "practice_desc": "Extracción de coordenadas PDB de ancho fijo, cálculo de mapas de contacto Ca-Ca y superposición estructural óptima de Kabsch.",
        "rubric_30": "Cálculo de RMSD con precisión de 6 decimales (1.0), mapa de contacto binario a 8.0 A (1.0) y pruebas de dominio (1.0).",
        "rubric_70": "Deducción matemática de la corrección del determinante en Kabsch para evitar reflexiones espaciales (30%), análisis del paisaje termodinámico (20%) e invariancia traslacional (20%)."
    },
    {
        "id": "BC06", "num": "06",
        "title": "Tecnologías de Secuenciación Masiva (NGS)",
        "block": "Bloque II: Algoritmos y Tecnologías Genómicas",
        "desc": "Química de secuenciación de 1G a 3G (Sanger, Illumina, PacBio, Nanoporo), modelo de Poisson de Lander-Waterman y sesgo por contenido GC.",
        "figure_img": "assets/figures/BC06-F01.png",
        "figure_alt": "Comparativa de las 3 generaciones de secuenciación masiva.",
        "figure_caption": "Evolución tecnológica: de la electroforesis capilar Sanger a lecturas cortas masivas por síntesis y moléculas únicas en tiempo real.",
        "pseudocode": "ALGORITMO: Modelo_Lander_Waterman_Cobertura\nENTRADA: Numero lecturas N, Longitud lectura L, Tamano genoma G\nSALIDA: Cobertura media C, Probabilidad base no cubierta P_gap\n\n1. Cobertura_Media C <- (N * L) / G\n2. Probabilidad_Gap <- exp(-C)\n3. Fraccion_Cubierta <- 1.0 - Probabilidad_Gap\n4. Retornar (C, Probabilidad_Gap, Fraccion_Cubierta)",
        "complexity": "O(1) cálculo estadístico directo.",
        "practice_title": "Práctica 6: Simulación NGS y Cobertura Lander-Waterman",
        "practice_kit": "assets/kits/kit_BC06.tar.gz",
        "practice_desc": "Cálculo de profundidad de cobertura genómica, estimación de gaps con Poisson y corrección de sesgo GC.",
        "rubric_30": "Evaluación correcta de Lander-Waterman (1.0), cálculo de cobertura sin errores (1.0) y validación (1.0).",
        "rubric_70": "Impacto de la tasa de error sistemática en Nanoporo vs Illumina (30%), justificación del diseño de bloques experimentales (20%) y resolución de variantes estructurales (20%)."
    },
    {
        "id": "BC07", "num": "07",
        "title": "Formatos FASTQ y Control de Calidad",
        "block": "Bloque II: Algoritmos y Tecnologías Genómicas",
        "desc": "Anatomía de registros FASTQ de 4 líneas, decodificación Phred+33, diagnóstico de módulos FastQC y algoritmo de recorte por ventana deslizante.",
        "figure_img": "assets/figures/BC07-F01.png",
        "figure_alt": "Anatomía del formato FASTQ y decodificación de calidad Phred+33.",
        "figure_caption": "Estructura FASTQ: Identificador, secuencia biológica, separador '+' y calidades codificadas en ASCII Phred+33.",
        "pseudocode": "ALGORITMO: Recorte_Ventana_Deslizante_Calidad\nENTRADA: Vector Calidades Q, Tamano Ventana W, Umbral Calidad Q_min\nSALIDA: Indice de corte optimo\n\n1. Para i desde 0 hasta (Longitud(Q) - W):\n     Media_Ventana <- Sumatorio(Q[i : i+W]) / W\n     Si Media_Ventana < Q_min:\n       Retornar i (Posicion de corte)\n2. Retornar Longitud(Q) (Lectura completa valida)",
        "complexity": "O(N) tiempo lineal con ventana deslizante optimizada.",
        "practice_title": "Práctica 7: Calidad Phred y Trimming de FASTQ",
        "practice_kit": "assets/kits/kit_BC07.tar.gz",
        "practice_desc": "Parser FASTQ de 4 líneas, conversión ASCII a Phred y recorte adaptativo por calidad y adaptadores.",
        "rubric_30": "Conversión Phred+33 exacta (1.0), recorte por ventana deslizante funcional (1.0) y autocontrol (1.0).",
        "rubric_70": "Diferenciación entre coordenadas 1-based cerradas (VCF/GFF) y 0-based semiabiertas (BED/BAM) (30%), diagnóstico de contaminación por adaptadores (20%) y robustez (20%)."
    },
    {
        "id": "BC08", "num": "08",
        "title": "Alineamiento y Mapeo Genómico SAM/BAM",
        "block": "Bloque II: Algoritmos y Tecnologías Genómicas",
        "desc": "Transformada de Burrows-Wheeler (BWT), FM-index en tiempo lineal O(L), formato SAM/BAM de 11 campos y operaciones de cadenas CIGAR (M, I, D, N, S).",
        "figure_img": "assets/figures/BC08-F01.png",
        "figure_alt": "Alineamiento Seed-and-Extend vs programación dinámica.",
        "figure_caption": "Heurística de indexación: BWT y FM-index para localización de semillas en O(L) seguido de extensión local.",
        "pseudocode": "ALGORITMO: BWT_LF_Mapping_Exact_Match\nENTRADA: Cadena BWT L_col, Matriz Occ(c, k), Array C_count(c), Patron P\nSALIDA: Rango de coincidencias exactas [sp, ep]\n\n1. char <- P[Longitud(P) - 1]\n2. sp <- C_count[char] + 1; ep <- C_count[char+1]\n3. Para i desde (Longitud(P) - 2) bajando hasta 0:\n     char <- P[i]\n     sp <- C_count[char] + Occ(char, sp - 1) + 1\n     ep <- C_count[char] + Occ(char, ep)\n     Si sp > ep: Retornar (0, 0) (Sin coincidencias)\n4. Retornar [sp, ep]",
        "complexity": "O(L) donde L es la longitud del patrón, independiente del tamaño del genoma.",
        "practice_title": "Práctica 8: BWT, FM-Index y Parsing de CIGAR",
        "practice_kit": "assets/kits/kit_BC08.tar.gz",
        "practice_desc": "Implementación de LF-mapping sobre BWT, decodificación de registros SAM y cálculo de longitud alineada en CIGAR.",
        "rubric_30": "Búsqueda exacta con FM-index (1.0), parser SAM de 11 columnas (1.0) y tests de ejecución (1.0).",
        "rubric_70": "Distinción entre MAPQ=0 y lecturas únicas de alta confianza (30%), manejo de alineamientos con splicing (operador N) (20%) y justificación de marcado de duplicados (20%)."
    },
    {
        "id": "BC09", "num": "09",
        "title": "Filogenia Molecular y Modelos Evolutivos",
        "block": "Bloque III: Filogenia Molecular y Regulación Génica",
        "desc": "Modelos de sustitución de nucleótidos (JC69, K2P), distancias corregidas, construcción de árboles (UPGMA, Neighbor-Joining) y soporte estadístico Bootstrap.",
        "figure_img": "assets/figures/BC09-F01.png",
        "figure_alt": "Modelos de evolución y árboles filogenéticos UPGMA vs NJ.",
        "figure_caption": "Inferencia filogenética: Corrección de distancias evolutivas y reconstrucción topológica por Neighbor-Joining.",
        "pseudocode": "ALGORITMO: Jukes_Cantor_JC69_Distance\nENTRADA: Proporcion de diferencias observadas p\nSALIDA: Distancia evolutiva corregida d\n\n1. Si p < 0 o p >= 0.75: Lanzar ValueError (Saturacion mutacional)\n2. d <- -0.75 * ln(1.0 - (4.0 / 3.0) * p)\n3. Retornar d",
        "complexity": "O(1) cálculo analítico por par de secuencias.",
        "practice_title": "Práctica 9: Distancias JC69 y Reconstrucción UPGMA",
        "practice_kit": "assets/kits/kit_BC09.tar.gz",
        "practice_desc": "Corrección de distancias por Jukes-Cantor, construcción de matriz de distancias y clustering jerárquico UPGMA/NJ.",
        "rubric_30": "Cálculo exacto de distancias JC69 (1.0), matriz simétrica con diagonal cero (1.0) y oráculos superados (1.0).",
        "rubric_70": "Explicación de la saturación mutacional cuando p >= 0.75 (30%), impacto de la asunción del reloj molecular en UPGMA frente a NJ (20%) y remuestreo Bootstrap (20%)."
    },
    {
        "id": "BC10", "num": "10",
        "title": "Regulación Génica, Clonación y Plásmidos",
        "block": "Bloque III: Filogenia Molecular y Regulación Génica",
        "desc": "Lógica del operón Lac (LacI / CAP-cAMP), atenuación en Trp, anatomía del plásmido pET-28a, diseño de cebadores in silico y métodos de ensamblaje (Gibson / Golden Gate).",
        "figure_img": "assets/figures/BC10-F01.png",
        "figure_alt": "Lógica combinatoria del operón Lac con Glucosa y Lactosa.",
        "figure_caption": "Regulación transcripcional: Activación por CAP-cAMP e inducción por alolactosa para la máxima expresión de beta-galactosidasa.",
        "pseudocode": "ALGORITMO: Calculo_Tm_Primer_SantaLucia\nENTRADA: Secuencia cebador S\nSALIDA: Temperatura de fusion Tm en grados Celsius\n\n1. L <- Longitud(S); GC_pct <- Porcentaje_GC(S)\n2. Si L < 14:\n     Tm <- (Contar(S, 'A') + Contar(S, 'T')) * 2 + (Contar(S, 'G') + Contar(S, 'C')) * 4\n3. Sino:\n     Tm <- 64.9 + 41.0 * (Contar(S, 'G') + Contar(S, 'C') - 16.4) / L\n4. Retornar Tm",
        "complexity": "O(L) tiempo lineal respecto a la longitud del oligonucleótido.",
        "practice_title": "Práctica 10: Diseño de Cebadores y Simulación de Enzimas",
        "practice_kit": "assets/kits/kit_BC10.tar.gz",
        "practice_desc": "Evaluación de la expresión del operón Lac, diseño de cebadores PCR con control de Tm y mapeo de sitios de restricción EcoRI.",
        "rubric_30": "Diseño de primers con Tm correcta (1.0), detección de sitios de corte (1.0) y verificación (1.0).",
        "rubric_70": "Análisis de represión catabólica por glucosa (30%), prevención de dímeros de cebador y horquillas (20%) y comparación Gibson vs Golden Gate (20%)."
    },
    {
        "id": "BC11", "num": "11",
        "title": "Estructura 3D de Proteínas y Validación",
        "block": "Bloque IV: Estructura, Dinámica y Biomedicina Computacional",
        "desc": "Determinación experimental (Rayos X, RMN, Cryo-EM), formato PDB/mmCIF, factores B térmicos de Debye-Waller, diagrama de Ramachandran y clasificaciones CATH/SCOP.",
        "figure_img": "assets/figures/BC11-F01.png",
        "figure_alt": "Comparativa de métodos experimentales 3D: Cristalografía, RMN y Cryo-EM.",
        "figure_caption": "Técnicas biofísicas de determinación estructural: ventajas, limitaciones de tamaño y resolución atómica.",
        "pseudocode": "ALGORITMO: BFactor_to_RMSF_Fluctuation\nENTRADA: Factor termico de Debye-Waller B\nSALIDA: Desplazamiento cuadratico medio RMSF en Angstroms\n\n1. Si B < 0: Lanzar ValueError\n2. U_cuadrado <- B / (8.0 * (pi ^ 2))\n3. RMSF <- sqrt(U_cuadrado)\n4. Retornar (U_cuadrado, RMSF)",
        "complexity": "O(1) tiempo constante por átomo.",
        "practice_title": "Práctica 11: Parsing PDB, Factores B y Ramachandran",
        "practice_kit": "assets/kits/kit_BC11.tar.gz",
        "practice_desc": "Lectura de líneas ATOM de 80 columnas, cálculo de distancias euclídeas 3D, conversión de factores B a RMSF y validación geométrica.",
        "rubric_30": "Parser de ancho fijo estricto (1.0), cálculo de RMSD y distancias 3D (1.0) y tests de ejecución (1.0).",
        "rubric_70": "Interpretación del factor B como flexibilidad térmica vs desorden estático (30%), validación de ángulos phi/psi en Ramachandran (20%) y justificación del estándar mmCIF (20%)."
    },
    {
        "id": "BC12", "num": "12",
        "title": "Modelado Computacional de Estructuras",
        "block": "Bloque IV: Estructura, Dinámica y Biomedicina Computacional",
        "desc": "Modelado por homología (curva de Rost, MODELLER), enhebrado (I-TASSER), ensamblaje ab initio en Rosetta con muestreo Monte Carlo Metropolis y métricas TM-score/MolProbity.",
        "figure_img": "assets/figures/BC12-F01.png",
        "figure_alt": "Curva de Rost y zonas de fiabilidad de modelado comparativo.",
        "figure_caption": "Umbrales de Rost: Zona segura (>30%), zona de penumbra (20-30%) y zona de medianoche (<20%).",
        "pseudocode": "ALGORITMO: Metropolis_Acceptance_Criterion\nENTRADA: Variacion de energia Delta_E, Temperatura T\nSALIDA: Probabilidad de aceptacion P\n\n1. Si T <= 0: Lanzar ValueError\n2. Si Delta_E <= 0:\n     Retornar 1.0 (Aceptacion incondicional)\n3. Sino:\n     Retornar exp(-Delta_E / T)",
        "complexity": "O(1) evaluación termodinámica estocástica.",
        "practice_title": "Práctica 12: Modelado por Homología y Muestreo Metropolis",
        "practice_kit": "assets/kits/kit_BC12.tar.gz",
        "practice_desc": "Cálculo de identidad de secuencia diana-plantilla, simulación del criterio de Metropolis y evaluación de TM-score y Clashscore.",
        "rubric_30": "Cálculo de identidad exacto (1.0), función Metropolis conforme (1.0) y evaluación de choques atómicos (1.0).",
        "rubric_70": "Impacto de los desfases de alineamiento (alignment shift) en el modelo 3D (30%), justificación del escape de mínimos locales en Rosetta (20%) y comparación TM-score vs RMSD (20%)."
    },
    {
        "id": "BC13", "num": "13",
        "title": "Aprendizaje Profundo y AlphaFold",
        "block": "Bloque IV: Estructura, Dinámica y Biomedicina Computacional",
        "desc": "Coevolución en MSAs, arquitectura de AlphaFold2 (Evoformer, Triangle Updates, IPA), métricas pLDDT (IDPs) y matrices PAE para dominios rígidos vs conectores flexibles.",
        "figure_img": "assets/figures/BC13-F01.png",
        "figure_alt": "Arquitectura de AlphaFold2 con Evoformer y Structure Module.",
        "figure_caption": "Aprendizaje profundo geométrico: procesamiento conjunto de MSA y matriz de pares hacia coordenadas 3D e incertidumbre.",
        "pseudocode": "ALGORITMO: Clasificacion_Confianza_pLDDT\nENTRADA: Puntuacion local pLDDT\nSALIDA: Categoria de fiabilidad\n\n1. Si pLDDT < 0 o pLDDT > 100: Lanzar ValueError\n2. Si pLDDT >= 90.0: Retornar 'VERY_HIGH'\n3. Si pLDDT >= 70.0: Retornar 'CONFIDENT'\n4. Si pLDDT >= 50.0: Retornar 'LOW'\n5. Retornar 'VERY_LOW_OR_IDP' (Proteina intrinsecamente desordenada)",
        "complexity": "O(1) clasificación por umbrales oficiales de DeepMind.",
        "practice_title": "Práctica 13: Auditoría de Confianza pLDDT y PAE",
        "practice_kit": "assets/kits/kit_BC13.tar.gz",
        "practice_desc": "Verificación de la desigualdad triangular en matrices 2D, clasificación cualitativa de pLDDT y diagnóstico de empaquetamiento interdominio con PAE.",
        "rubric_30": "Clasificación rigurosa de bandas pLDDT (1.0), media aritmética y evaluación PAE (1.0) y oráculos superados (1.0).",
        "rubric_70": "Discriminación entre baja confianza del modelo y regiones intrínsecamente desordenadas IDPs (30%), análisis de orientaciones rígidas vs flexibles en PAE (20%) y auditoría bioinformática responsable (20%)."
    },
    {
        "id": "BC14", "num": "14",
        "title": "Dinámica Molecular, Docking y Cribado Virtual",
        "block": "Bloque IV: Estructura, Dinámica y Biomedicina Computacional",
        "desc": "Dinámica molecular clásica (Verlet, campos de fuerza), docking con AutoDock Vina, conversión termodinámica a Kd, similitud de Tanimoto y Regla de 5 de Lipinski.",
        "figure_img": "assets/figures/BC14-F01.png",
        "figure_alt": "Campos de fuerza macromoleculares y términos energéticos.",
        "figure_caption": "Descomposición energética: potenciales enlazados (enlaces, ángulos, diedros) y no enlazados (Lennard-Jones y Coulomb).",
        "pseudocode": "ALGORITMO: Evaluacion_Regla_5_Lipinski\nENTRADA: Peso Molecular MW, Lipofilia LogP, Donadores HBD, Aceptores HBA\nSALIDA: Numero de violaciones, Booleano Drug_Like\n\n1. Violaciones <- 0\n2. Si MW > 500.0: Violaciones <- Violaciones + 1\n3. Si LogP > 5.0: Violaciones <- Violaciones + 1\n4. Si HBD > 5: Violaciones <- Violaciones + 1\n5. Si HBA > 10: Violaciones <- Violaciones + 1\n6. Drug_Like <- (Violaciones <= 1)\n7. Retornar (Violaciones, Drug_Like)",
        "complexity": "O(1) evaluación de propiedades fisicoquímicas.",
        "practice_title": "Práctica 14: Cribado Virtual, Docking y Fármaco-Similitud",
        "practice_kit": "assets/kits/kit_BC14.tar.gz",
        "practice_desc": "Integración del paso de posición de Verlet, conversión de afinidad delta G a Kd micromolar, similitud de Tanimoto y cribado de Lipinski.",
        "rubric_30": "Cálculo termodinámico de Kd exacto (1.0), filtro de Lipinski funcional (1.0) y paso de Verlet verificado (1.0).",
        "rubric_70": "Limitaciones del docking de receptor rígido y necesidad del ajuste inducido (30%), interpretación de huellas 2D en cribado masivo (20%) y síntesis integradora de la asignatura (20%)."
    }
]

def step1_rasterize_figures():
    print("1. Rasterizando y copiando figuras vectoriales a docs/assets/figures/...")
    FIGS_DIR.mkdir(parents=True, exist_ok=True)
    for topic in TOPICS_BC:
        ch_num = topic["num"]
        ch_dir = REGEN_ROOT / f"capitulos/BC-CH{ch_num}/figures"
        for f_idx in [1, 2, 3]:
            pdf_path = ch_dir / f"BC{ch_num}-F0{f_idx}.pdf"
            png_target = FIGS_DIR / f"BC{ch_num}-F0{f_idx}.png"
            if pdf_path.exists():
                # Convert PDF to PNG using pdftoppm
                cmd = ["pdftoppm", "-png", "-r", "200", "-singlefile", str(pdf_path), str(FIGS_DIR / f"BC{ch_num}-F0{f_idx}")]
                subprocess.run(cmd, check=True)
                print(f"  -> Generada: {png_target.name}")

def step2_copy_pdfs():
    print("2. Copiando capítulos individuales y libro completo a docs/assets/capitulos/...")
    CAPS_DIR.mkdir(parents=True, exist_ok=True)
    # Libro completo
    book_src = REGEN_ROOT / "book.pdf"
    if book_src.exists():
        shutil.copy2(book_src, CAPS_DIR / "Libro_Biologia_Computacional_v3.0.pdf")
        print("  -> Copiado: Libro_Biologia_Computacional_v3.0.pdf")
    # Capítulos individuales
    for topic in TOPICS_BC:
        ch_num = topic["num"]
        ch_pdf = REGEN_ROOT / f"capitulos/BC-CH{ch_num}/chapter.pdf"
        target_pdf = CAPS_DIR / f"BC{ch_num}_capitulo_v3.0.pdf"
        if ch_pdf.exists():
            shutil.copy2(ch_pdf, target_pdf)
            print(f"  -> Copiado: {target_pdf.name}")

def step3_generate_kits():
    print("3. Generando kits de práctica descargables en docs/assets/kits/...")
    KITS_DIR.mkdir(parents=True, exist_ok=True)
    for topic in TOPICS_BC:
        ch_num = topic["num"]
        ch_dir = REGEN_ROOT / f"capitulos/BC-CH{ch_num}"
        verif_dir = ch_dir / "verification"
        kit_tar = KITS_DIR / f"kit_BC{ch_num}.tar.gz"
        
        # Create a clean temporary directory for the kit
        tmp_kit = Path(f"/tmp/kit_BC{ch_num}")
        if tmp_kit.exists():
            shutil.rmtree(tmp_kit)
        tmp_kit.mkdir(parents=True)
        
        # Copy verification scripts and environment
        if (verif_dir / "practice_checks.py").exists():
            shutil.copy2(verif_dir / "practice_checks.py", tmp_kit / "practice_checks.py")
        if (verif_dir / "chapter_checks.py").exists():
            shutil.copy2(verif_dir / "chapter_checks.py", tmp_kit / "chapter_checks.py")
        if (verif_dir / "environment.txt").exists():
            shutil.copy2(verif_dir / "environment.txt", tmp_kit / "environment.txt")
            
        # Create a workspace initialization script
        workspace_sh = tmp_kit / "create_workspace.sh"
        workspace_sh.write_text(f"""#!/usr/bin/env bash
# create_workspace.sh - Inicializa el entorno de trabajo para la Practica BC{ch_num}
set -e

DIR_ENTREGA="${{1:-MiEntrega_BC{ch_num}}}"
mkdir -p "$DIR_ENTREGA/notas"
mkdir -p "$DIR_ENTREGA/src"

cp practice_checks.py "$DIR_ENTREGA/src/"
if [ -f chapter_checks.py ]; then cp chapter_checks.py "$DIR_ENTREGA/src/"; fi

cat << 'EOF' > "$DIR_ENTREGA/notas/respuestas.tsv"
# Plantilla de Respuestas - Practica BC{ch_num}
# Modulo: {topic['title']}
METRIC\\tVALOR\\tDEFENSA_BREVE
DELIVERY_STATUS\\tPENDIENTE\\tInicializacion de entorno
EOF

echo "Espacio de trabajo creado en: $DIR_ENTREGA"
""", encoding="utf-8")
        workspace_sh.chmod(0o755)
        
        # Create check_practice_delivery.sh
        check_sh = tmp_kit / "check_practice_delivery.sh"
        check_sh.write_text(f"""#!/usr/bin/env bash
# check_practice_delivery.sh - Autocontrol de entrega para Practica BC{ch_num}
set -e

DIR_ENTREGA="${{1:-MiEntrega_BC{ch_num}}}"
if [ ! -d "$DIR_ENTREGA" ]; then
    echo "ERROR: No existe el directorio de entrega: $DIR_ENTREGA"
    exit 1
fi

echo "Verificando ejecucion de oraculos de la Practica BC{ch_num}..."
python3 "$DIR_ENTREGA/src/practice_checks.py" > /dev/null 2>&1 || {{
    echo "ERROR: Fallo en la ejecucion de practice_checks.py"
    exit 1
}}

echo "[DELIVERY_OK] Practica BC{ch_num} verificada con exito (3.0 / 3.0 pts)"
""", encoding="utf-8")
        check_sh.chmod(0o755)
        
        # Archive tar.gz
        with tarfile.open(kit_tar, "w:gz") as tar:
            for item in tmp_kit.iterdir():
                tar.add(item, arcname=item.name)
        print(f"  -> Generado: {kit_tar.name}")

def step4_generate_markdown_pages():
    print("4. Generando páginas Markdown en docs/biologia-computacional/...")
    BC_MD_DIR.mkdir(parents=True, exist_ok=True)
    
    # Save topics JSON
    with open(ASSETS_DIR / "topics_data_bc.json", "w", encoding="utf-8") as f:
        json.dump(TOPICS_BC, f, indent=2, ensure_ascii=False)
        
    for t in TOPICS_BC:
        num = t["num"]
        md_file = BC_MD_DIR / f"bc{num}.md"
        content = f"""---
title: BC{num} - {t['title']}
description: {t['desc']}
---

# BC{num} · {t['title']}

<div class="admonition note">
<p class="admonition-title">{t['block']}</p>
<p>{t['desc']}</p>
</div>

!!! warning "Entrega Oficial en Campus Virtual"
    **Importante:** La entrega, evaluación y calificación oficial de esta práctica se realiza **exclusivamente a través del Campus Virtual**. Los kits descargables aquí son para experimentación y autoevaluación local (`check_practice_delivery.sh`).

---

=== "📖 Capítulo Teórico & Pseudocódigo"

    !!! info "📖 Material de Estudio Teórico (Versión 3.0)"
        Puede consultar y descargar el capítulo individual en formato PDF para preparar esta sesión:

        [📥 Descargar Capítulo BC{num} (PDF · v3.0)](../assets/capitulos/BC{num}_capitulo_v3.0.pdf){{ .md-button .md-button--primary }}

    ### Algoritmo Estructurado y Especificación Formal

    ```text
{t['pseudocode']}
    ```

    ???+ info "Complejidad Asintótica Formal"
        **Análisis:** {t['complexity']}

=== "📊 Diagramas Vectoriales"

    ### Diagrama Conceptual de Referencia (Figura 1)

    ![{t['figure_alt']}](../assets/figures/BC{num}-F01.png)

    *{t['figure_caption']}*

    ---

    ### Esquemas Complementarios del Capítulo

    <div class="grid cards" markdown>
    - ![{t['title']} - Esquema 2](../assets/figures/BC{num}-F02.png)
    - ![{t['title']} - Esquema 3](../assets/figures/BC{num}-F03.png)
    </div>

=== "💻 Laboratorio & Descarga de Kit"

    ### {t['practice_title']}

    {t['practice_desc']}

    [📥 Descargar Kit de Práctica (kit_BC{num}.tar.gz)](../assets/kits/{os.path.basename(t['practice_kit'])}){{ .md-button .md-button--primary }}

    #### 1. Inicialización del Espacio de Trabajo
    ```bash
    tar -xzf kit_BC{num}.tar.gz
    bash create_workspace.sh MiEntrega_BC{num}
    cd MiEntrega_BC{num}
    ```

    #### 2. Autoevaluación Local (DELIVERY_OK)
    ```bash
    bash check_practice_delivery.sh MiEntrega_BC{num}
    # Debe emitir: [DELIVERY_OK] Practica BC{num} verificada con exito (3.0 / 3.0 pts)
    ```

    #### 3. Empaquetado y Entrega en Campus Virtual
    Comprima su carpeta de entrega conteniendo sus scripts y súbala al Campus Virtual:
    ```bash
    tar -czf MiEntrega_BC{num}.tar.gz MiEntrega_BC{num}/
    ```

=== "⚡ Recursos Interactivos"

    ### Espacio de Experimentación y Modelado Computacional

    <div class="admonition tip">
    <p class="admonition-title">Entorno Interactivo y Datos Reproducibles</p>
    <p>Este módulo cuenta con implementaciones deterministas en Python 3.9 estándar (<code>SEED=42</code>) y oráculos formales incluidos en el kit de práctica.</p>
    </div>

=== "📋 Rúbrica ADR-001 (30/70)"

    ### Criterios Estandarizados de Evaluación

    | Componente | Peso | Criterio de Evaluación |
    | :--- | :---: | :--- |
    | **Entrega Técnica Automatizada** | **30% (3.0 pts)** | {t['rubric_30']} |
    | **Razonamiento Bioinformático & Robustez** | **70% (7.0 pts)** | {t['rubric_70']} |

    !!! note "Marco de IA Responsable"
        - **Permitido con declaración:** Lluvia de ideas, depuración de sintaxis y consultas conceptuales.
        - **Restringido:** Generación directa de soluciones de entrega sin comprensión o verificación formal.
        - **No permitido:** Invención de referencias bibliográficas, alteración de datos experimentales o entrega no comprendida.

---

[Volver al Índice de Biología Computacional](index.md){{ .md-button }}
"""
        md_file.write_text(content, encoding="utf-8")
        print(f"  -> Generado: {md_file.name}")
        
    # Generate index.md
    index_md = BC_MD_DIR / "index.md"
    index_content = """# Biología Computacional · Portal Docente

Bienvenido al portal de la asignatura **Biología Computacional** (Curso 2026–2027), perteneciente al Plan de Innovación Docente.

!!! info "📖 Libro de Texto Consolidado (Versión 3.0)"
    El manual completo de la asignatura está disponible para consulta de estudiantes:
    
    [📥 Descargar Libro Completo de Biología Computacional (240 págs · PDF)](../assets/capitulos/Libro_Biologia_Computacional_v3.0.pdf){ .md-button .md-button--primary }

---

## Estructura de Módulos Temáticos

<div class="grid cards" markdown>

-   **Bloque I: Fundamentos Biológicos y Biofísicos**
    ---
    - [BC01 · Dogma Central y Representación Digital](bc01.md)
    - [BC02 · Biofísica de Proteínas y Estructura Secundaria](bc02.md)
    - [BC03 · Arquitectura del Genoma y Variación de Secuencia](bc03.md)
    - [BC04 · Transcripción, Splicing y Expresión Génica](bc04.md)
    - [BC05 · Plegamiento y Geometría Macromolecular](bc05.md)

-   **Bloque II: Algoritmos y Tecnologías Genómicas**
    ---
    - [BC06 · Tecnologías de Secuenciación Masiva (NGS)](bc06.md)
    - [BC07 · Formatos FASTQ y Control de Calidad](bc07.md)
    - [BC08 · Alineamiento y Mapeo Genómico SAM/BAM](bc08.md)

-   **Bloque III: Filogenia Molecular y Regulación Génica**
    ---
    - [BC09 · Filogenia Molecular y Modelos Evolutivos](bc09.md)
    - [BC10 · Regulación Génica, Clonación y Plásmidos](bc10.md)

-   **Bloque IV: Estructura, Dinámica y Biomedicina**
    ---
    - [BC11 · Estructura 3D de Proteínas y Validación](bc11.md)
    - [BC12 · Modelado Computacional de Estructuras](bc12.md)
    - [BC13 · Aprendizaje Profundo y AlphaFold](bc13.md)
    - [BC14 · Dinámica Molecular, Docking y Cribado Virtual](bc14.md)

</div>
"""
    index_md.write_text(index_content, encoding="utf-8")
    print("  -> Generado: docs/biologia-computacional/index.md")

def step5_update_config():
    print("5. Actualizando config_capitulos.json...")
    cfg_file = PID_ROOT / "config_capitulos.json"
    if cfg_file.exists():
        with open(cfg_file, "r", encoding="utf-8") as f:
            cfg = json.load(f)
    else:
        cfg = {}
        
    for t in TOPICS_BC:
        num = t["num"]
        cfg[f"BC{num}"] = {
            "enabled": True,
            "active_version": "v3.0",
            "versions": {
                "v3.0": f"assets/capitulos/BC{num}_capitulo_v3.0.pdf"
            }
        }
    with open(cfg_file, "w", encoding="utf-8") as f:
        json.dump(cfg, f, indent=2, ensure_ascii=False)
    print("  -> config_capitulos.json actualizado con BC01..BC14")

def main():
    step1_rasterize_figures()
    step2_copy_pdfs()
    step3_generate_kits()
    step4_generate_markdown_pages()
    step5_update_config()
    print("\n✅ Sincronización completa de Biología Computacional V3.0 finalizada.")

if __name__ == "__main__":
    main()
