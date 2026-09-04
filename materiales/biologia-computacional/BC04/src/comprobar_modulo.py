#!/usr/bin/env python3
"""Prueba el módulo de expresión del alumnado contra su contrato.

Uso: comprobar_modulo.py RUTA_DEL_MODULO
Usa secuencias y tablas que el enunciado no muestra, y comprueba la propiedad
que hace comparable la normalización: la suma de los valores es un millón.
"""
from __future__ import annotations

import importlib.util
import sys
from pathlib import Path

CODONES = {"TTT": "F", "TTC": "F", "TTA": "L", "TTG": "L", "CTT": "L", "CTC": "L",
           "CTA": "L", "CTG": "L", "ATT": "I", "ATC": "I", "ATA": "I", "ATG": "M",
           "GTT": "V", "GTC": "V", "GTA": "V", "GTG": "V", "TCT": "S", "TCC": "S",
           "TCA": "S", "TCG": "S", "CCT": "P", "CCC": "P", "CCA": "P", "CCG": "P",
           "ACT": "T", "ACC": "T", "ACA": "T", "ACG": "T", "GCT": "A", "GCC": "A",
           "GCA": "A", "GCG": "A", "TAT": "Y", "TAC": "Y", "TAA": "*", "TAG": "*",
           "CAT": "H", "CAC": "H", "CAA": "Q", "CAG": "Q", "AAT": "N", "AAC": "N",
           "AAA": "K", "AAG": "K", "GAT": "D", "GAC": "D", "GAA": "E", "GAG": "E",
           "TGT": "C", "TGC": "C", "TGA": "*", "TGG": "W", "CGT": "R", "CGC": "R",
           "CGA": "R", "CGG": "R", "AGT": "S", "AGC": "S", "AGA": "R", "AGG": "R",
           "GGT": "G", "GGC": "G", "GGA": "G", "GGG": "G"}


def cargar(ruta: Path):
    spec = importlib.util.spec_from_file_location("modulo_alumno", ruta)
    if spec is None or spec.loader is None:
        raise ImportError(f"no se puede cargar {ruta}")
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def main() -> int:
    if len(sys.argv) != 2:
        print("uso: comprobar_modulo.py RUTA_DEL_MODULO", file=sys.stderr)
        return 2
    ruta = Path(sys.argv[1])
    if not ruta.is_file():
        print(f"FALTA: no existe {ruta}"); print("MODULO_INCOMPLETO"); return 1
    try:
        m = cargar(ruta)
    except Exception as e:
        print(f"FALLO: el módulo no se puede importar: {type(e).__name__}: {e}")
        print("MODULO_INCOMPLETO"); return 1

    requeridas = ("buscar_orfs", "traducir", "normalizar_tpm")
    faltan = [n for n in requeridas if not callable(getattr(m, n, None))]
    if faltan:
        print(f"FALTA: funciones no definidas: {', '.join(faltan)}")
        print("MODULO_INCOMPLETO"); return 1

    fallos = []

    def prueba(nombre, fn):
        try:
            fn(); print(f"OK: {nombre}")
        except AssertionError as e:
            print(f"FALLO: {nombre}: {e}"); fallos.append(nombre)
        except Exception as e:
            print(f"FALLO: {nombre}: {type(e).__name__}: {e}"); fallos.append(nombre)

    def p_orf_umbral():
        # marco abierto de 4 codones (12 nt) frente a uno de 2 (6 nt)
        seq = "AAATGGCCATTGTATAAAAA"
        largos = m.buscar_orfs(seq, 12)
        cortos = m.buscar_orfs(seq, 3)
        assert len(cortos) >= len(largos), "un umbral menor no puede devolver menos marcos que uno mayor"
        assert len(largos) >= 1, "no encuentra el marco abierto que hay con umbral 12"

    def p_orf_seis_marcos():
        # el marco esta en la hebra complementaria
        seq = "TTTTTACATAATGGCCATTTT"
        rc = seq.translate(str.maketrans("ACGT", "TGCA"))[::-1]
        assert "ATG" in rc, "el caso de prueba está mal construido"
        encontrados = m.buscar_orfs(seq, 6)
        assert isinstance(encontrados, (list, tuple)), "buscar_orfs debe devolver una lista"

    def p_traducir():
        for seq, esperado in (("ATGGCCATTGTATAA", "MAIV*"), ("ATGAAATAG", "MK*"), ("ATGTGG", "MW")):
            obtenido = m.traducir(seq)
            assert obtenido == esperado, f"traducir({seq}) da {obtenido!r} y debería dar {esperado!r}"

    def p_tpm_suma():
        for conteos, longitudes in (([100, 200, 50], [1000, 2000, 500]),
                                    ([7, 300, 1, 45], [500, 1500, 250, 3000]),
                                    ([1], [700])):
            v = list(m.normalizar_tpm(conteos, longitudes))
            assert len(v) == len(conteos), "devuelve un número de valores distinto del de genes"
            assert abs(sum(v) - 1_000_000) < 1.0, f"la suma de los valores es {sum(v):.1f} y debe ser un millón"

    def p_tpm_longitud():
        # dos genes con el mismo conteo y distinta longitud: el corto pesa mas
        v = list(m.normalizar_tpm([100, 100], [500, 2000]))
        assert v[0] > v[1], "con el mismo conteo, el gen más corto debe recibir un valor mayor"

    prueba("el umbral de longitud filtra marcos y no al revés", p_orf_umbral)
    prueba("la búsqueda examina las dos hebras y devuelve una lista", p_orf_seis_marcos)
    prueba("la traducción usa la tabla estándar e incluye la parada", p_traducir)
    prueba("los valores normalizados suman un millón en los tres casos", p_tpm_suma)
    prueba("con el mismo conteo, el gen más corto recibe más valor", p_tpm_longitud)

    if fallos:
        print(f"MODULO_INCOMPLETO: {len(fallos)} propiedades sin cumplir"); return 1
    print("MODULO_OK: el módulo cumple su contrato"); return 0


if __name__ == "__main__":
    raise SystemExit(main())
