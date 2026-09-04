#!/usr/bin/env python3
"""Prueba el módulo de diseño del alumnado contra su contrato."""
from __future__ import annotations

import importlib.util
import sys
from pathlib import Path


def cargar(ruta: Path):
    spec = importlib.util.spec_from_file_location("modulo_alumno", ruta)
    if spec is None or spec.loader is None:
        raise ImportError(f"no se puede cargar {ruta}")
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def tm_ref(seq: str) -> float:
    gc = 100.0 * (seq.count("G") + seq.count("C")) / len(seq)
    return 81.5 + 0.41 * gc - 675.0 / len(seq)


def main() -> int:
    if len(sys.argv) != 2:
        print("uso: comprobar_diseno.py RUTA_DEL_MODULO", file=sys.stderr)
        return 2
    ruta = Path(sys.argv[1])
    if not ruta.is_file():
        print(f"FALTA: no existe {ruta}")
        print("DISENO_INCOMPLETO")
        return 1
    try:
        m = cargar(ruta)
    except Exception as e:
        print(f"FALLO: no se puede importar: {type(e).__name__}: {e}")
        print("DISENO_INCOMPLETO")
        return 1

    req = ("contenido_gc", "temperatura_fusion", "dianas_restriccion")
    faltan = [n for n in req if not callable(getattr(m, n, None))]
    if faltan:
        print(f"FALTA: funciones no definidas: {', '.join(faltan)}")
        print("DISENO_INCOMPLETO")
        return 1

    fallos = []

    def prueba(nombre, fn):
        try:
            ok, detalle = fn()
        except NotImplementedError:
            fallos.append(f"{nombre}: sin implementar")
            return
        except Exception as e:
            fallos.append(f"{nombre}: {type(e).__name__}: {e}")
            return
        if not ok:
            fallos.append(f"{nombre}: {detalle}")

    def cerca(a, b, tol=1e-6):
        return abs(a - b) <= tol

    # contenido_gc: valor puntual y los dos extremos
    def gc_modelo():
        v = m.contenido_gc("GGAATTCATGGTGAGCAAGGGCGAG")
        return cerca(v, 56.0, 1e-9), f"esperado 56.0, obtenido {v}"

    def gc_extremos():
        alto = m.contenido_gc("GCGCGCGCGC")
        bajo = m.contenido_gc("ATATATATAT")
        return (cerca(alto, 100.0) and cerca(bajo, 0.0)), f"esperado 100.0 y 0.0, obtenido {alto} y {bajo}"

    # temperatura_fusion: los dos cebadores del fichero de datos
    def tm_modelo():
        v = m.temperatura_fusion("GGAATTCATGGTGAGCAAGGGCGAG")
        return cerca(v, 77.46, 5e-3), f"esperado 77.46, obtenido {v}"

    def tm_reverso():
        s = "GGATCCTTACTTGTACAGCTCGTCCAT"
        v = m.temperatura_fusion(s)
        return cerca(v, tm_ref(s), 5e-3), f"esperado {tm_ref(s):.2f}, obtenido {v}"

    # la relación que la fórmula impone: a igual longitud, más GC es más Tm
    def tm_monotona():
        a = m.temperatura_fusion("GCGCGGCGCCGGCGCGGCCGCGGCG")
        b = m.temperatura_fusion("AATTATTAATTTAATATTAAATTAT")
        return a > b, f"con la misma longitud, el cebador rico en GC debe fundir más alto: {a} frente a {b}"

    # guarda de dominio: por debajo de 10 nucleótidos la fórmula no se aplica
    def tm_guarda():
        try:
            v = m.temperatura_fusion("ATGCAT")
        except ValueError:
            return True, ""
        return False, f"debía lanzar ValueError con 6 nucleótidos y devolvió {v}"

    def gc_guarda():
        try:
            v = m.contenido_gc("")
        except (ValueError, ZeroDivisionError):
            return True, ""
        return False, f"debía rechazar la secuencia vacía y devolvió {v}"

    # dianas_restriccion: posiciones en base 1, todas las apariciones
    def dianas_modelo():
        v = list(m.dianas_restriccion("GGAATTCATGGTGAGCAAGGGCGAG", "GAATTC"))
        return v == [2], f"esperado [2], obtenido {v}"

    def dianas_varias():
        v = list(m.dianas_restriccion("GAATTCAAAGAATTC", "GAATTC"))
        return v == [1, 10], f"esperado [1, 10], obtenido {v}"

    def dianas_solapadas():
        v = list(m.dianas_restriccion("AAAA", "AA"))
        return v == [1, 2, 3], f"las apariciones solapadas cuentan: esperado [1, 2, 3], obtenido {v}"

    def dianas_ausente():
        v = list(m.dianas_restriccion("GGATCCGGATCC", "GAATTC"))
        return v == [], f"esperado [], obtenido {v}"

    for nombre, fn in (
        ("contenido_gc/cebador modelo", gc_modelo),
        ("contenido_gc/extremos", gc_extremos),
        ("contenido_gc/secuencia vacía", gc_guarda),
        ("temperatura_fusion/cebador modelo", tm_modelo),
        ("temperatura_fusion/cebador reverso", tm_reverso),
        ("temperatura_fusion/monotonía en GC", tm_monotona),
        ("temperatura_fusion/guarda de longitud", tm_guarda),
        ("dianas_restriccion/EcoRI en el modelo", dianas_modelo),
        ("dianas_restriccion/dos apariciones", dianas_varias),
        ("dianas_restriccion/solapamiento", dianas_solapadas),
        ("dianas_restriccion/motivo ausente", dianas_ausente),
    ):
        prueba(nombre, fn)

    if fallos:
        for f in fallos:
            print(f"FALLO: {f}")
        print("DISENO_INCOMPLETO")
        return 1
    print("DISENO_OK: las tres funciones cumplen el contrato (11 comprobaciones)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
