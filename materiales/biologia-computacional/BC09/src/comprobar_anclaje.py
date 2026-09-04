#!/usr/bin/env python3
"""Prueba el módulo de anclaje del alumnado contra su contrato."""
from __future__ import annotations

import importlib.util
import math
import sys
from pathlib import Path


def cargar(ruta: Path):
    spec = importlib.util.spec_from_file_location("modulo_alumno", ruta)
    if spec is None or spec.loader is None:
        raise ImportError(f"no se puede cargar {ruta}")
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def jc69_ref(p: float) -> float:
    return -0.75 * math.log(1.0 - (4.0 / 3.0) * p)


def main() -> int:
    if len(sys.argv) != 2:
        print("uso: comprobar_anclaje.py RUTA_DEL_MODULO", file=sys.stderr); return 2
    ruta = Path(sys.argv[1])
    if not ruta.is_file():
        print(f"FALTA: no existe {ruta}"); print("ANCLAJE_INCOMPLETO"); return 1
    try:
        m = cargar(ruta)
    except Exception as e:
        print(f"FALLO: no se puede importar: {type(e).__name__}: {e}"); print("ANCLAJE_INCOMPLETO"); return 1
    req = ("p_distance", "jc69", "primera_fusion")
    faltan = [n for n in req if not callable(getattr(m, n, None))]
    if faltan:
        print(f"FALTA: funciones no definidas: {', '.join(faltan)}"); print("ANCLAJE_INCOMPLETO"); return 1

    fallos = []
    def prueba(nombre, fn):
        try:
            fn(); print(f"OK: {nombre}")
        except AssertionError as e:
            print(f"FALLO: {nombre}: {e}"); fallos.append(nombre)
        except Exception as e:
            print(f"FALLO: {nombre}: {type(e).__name__}: {e}"); fallos.append(nombre)

    def p_pdist():
        casos = [("AAAA", "AAAA", 0.0), ("AAAA", "AAAT", 0.25), ("ACGT", "TGCA", 1.0),
                 ("AACCGGTT", "AACCGGTA", 0.125)]
        for a, b, esp in casos:
            v = float(m.p_distance(a, b))
            assert abs(v - esp) < 1e-9, f"entre {a} y {b} da {v} y debería dar {esp}"

    def p_pdist_longitud():
        try:
            m.p_distance("AAA", "AA")
        except ValueError:
            return
        raise AssertionError("acepta dos secuencias de longitud distinta, que no están alineadas")

    def p_jc69():
        for p in (0.0, 0.05, 0.125, 0.4, 0.7):
            v = float(m.jc69(p))
            assert abs(v - jc69_ref(p)) < 1e-9, f"para p={p} da {v:.6f} y la fórmula da {jc69_ref(p):.6f}"
        assert float(m.jc69(0.2)) > 0.2, "la corrección siempre aumenta la distancia observada"

    def p_jc69_dominio():
        for p in (0.75, 0.8, 1.0, -0.1):
            try:
                m.jc69(p)
            except ValueError:
                continue
            raise AssertionError(f"acepta p={p}, que queda fuera del dominio de la corrección")

    def p_fusion():
        for d13, d23 in ((0.404247, 0.656602), (0.2, 0.2), (1.0, 0.0)):
            esp = (d13 + d23) / 2
            v = float(m.primera_fusion(d13, d23))
            assert abs(v - esp) < 1e-9, f"con {d13} y {d23} da {v:.6f}; con dos hojas los pesos son iguales y sale {esp:.6f}"

    prueba("la distancia observada cuenta las posiciones que difieren", p_pdist)
    prueba("dos secuencias de longitud distinta se rechazan", p_pdist_longitud)
    prueba("la corrección sigue la fórmula y siempre aumenta la distancia", p_jc69)
    prueba("la corrección rechaza los valores fuera de su dominio", p_jc69_dominio)
    prueba("la primera fusión promedia con pesos iguales", p_fusion)

    if fallos:
        print(f"ANCLAJE_INCOMPLETO: {len(fallos)} propiedades sin cumplir"); return 1
    print("ANCLAJE_OK: el módulo de anclaje cumple su contrato"); return 0


if __name__ == "__main__":
    raise SystemExit(main())
