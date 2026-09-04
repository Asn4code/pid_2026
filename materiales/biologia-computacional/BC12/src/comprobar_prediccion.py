#!/usr/bin/env python3
"""Prueba el módulo de predicción del alumnado contra su contrato."""
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


def main() -> int:
    if len(sys.argv) != 2:
        print("uso: comprobar_prediccion.py RUTA_DEL_MODULO", file=sys.stderr)
        return 2
    ruta = Path(sys.argv[1])
    if not ruta.is_file():
        print(f"FALTA: no existe {ruta}")
        print("PREDICCION_INCOMPLETA")
        return 1
    try:
        m = cargar(ruta)
    except Exception as e:
        print(f"FALLO: no se puede importar: {type(e).__name__}: {e}")
        print("PREDICCION_INCOMPLETA")
        return 1

    req = ("identidad_secuencia", "zona_de_fiabilidad", "probabilidad_metropolis", "clashscore")
    faltan = [n for n in req if not callable(getattr(m, n, None))]
    if faltan:
        print(f"FALTA: funciones no definidas: {', '.join(faltan)}")
        print("PREDICCION_INCOMPLETA")
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

    # identidad_secuencia
    def id_puntual():
        v = m.identidad_secuencia("ACDEFGHIKLMNPQRSTVWY", "ACDEFGHIKLMNPQRSTVWA")
        return cerca(v, 95.0, 1e-9), f"esperado 95.0, obtenido {v}"

    def id_extremos():
        a = m.identidad_secuencia("ACDE", "ACDE")
        b = m.identidad_secuencia("AAAA", "CCCC")
        return (cerca(a, 100.0) and cerca(b, 0.0)), f"esperado 100.0 y 0.0, obtenido {a} y {b}"

    def id_huecos():
        # una posición con hueco en ambas no cuenta como coincidencia
        v = m.identidad_secuencia("AC-E", "AC-E")
        return cerca(v, 75.0), f"el hueco alineado con hueco no es identidad: esperado 75.0, obtenido {v}"

    def id_longitudes():
        try:
            v = m.identidad_secuencia("ACDE", "ACD")
        except ValueError:
            return True, ""
        return False, f"debía rechazar longitudes distintas y devolvió {v}"

    # zona_de_fiabilidad
    def zonas():
        casos = ((90.0, "segura"), (35.0, "segura"), (30.0, "segura"),
                 (29.9, "penumbra"), (25.0, "penumbra"), (20.0, "penumbra"),
                 (19.9, "medianoche"), (15.0, "medianoche"))
        malos = [(i, e, m.zona_de_fiabilidad(i)) for i, e in casos if m.zona_de_fiabilidad(i) != e]
        return not malos, "; ".join(f"{i}% esperaba {e} y devolvió {o}" for i, e, o in malos)

    # probabilidad_metropolis
    def metro_puntual():
        v = m.probabilidad_metropolis(300.0, 300.0)
        return cerca(v, math.exp(-1.0), 1e-6), f"esperado {math.exp(-1.0):.6f}, obtenido {v}"

    def metro_mejora():
        a = m.probabilidad_metropolis(-50.0, 300.0)
        b = m.probabilidad_metropolis(0.0, 300.0)
        return (cerca(a, 1.0) and cerca(b, 1.0)), f"un movimiento que no empeora se acepta siempre: obtenido {a} y {b}"

    def metro_monotona():
        # a igual empeoramiento, más parámetro de muestreo es más tolerancia
        a = m.probabilidad_metropolis(300.0, 600.0)
        b = m.probabilidad_metropolis(300.0, 150.0)
        return a > b, f"con T mayor la aceptación debe subir: {a} frente a {b}"

    def metro_guarda():
        for t in (0.0, -1.0):
            try:
                v = m.probabilidad_metropolis(300.0, t)
            except ValueError:
                continue
            return False, f"debía lanzar ValueError con T={t} y devolvió {v}"
        return True, ""

    # clashscore
    def clash_puntual():
        v = m.clashscore(2, 1000)
        return cerca(v, 2.0), f"esperado 2.0, obtenido {v}"

    def clash_escala():
        v = m.clashscore(5, 2500)
        return cerca(v, 2.0), f"el Clashscore es por cada 1000 átomos: esperado 2.0, obtenido {v}"

    def clash_guarda():
        for c, a in ((0, 0), (-1, 1000)):
            try:
                v = m.clashscore(c, a)
            except ValueError:
                continue
            return False, f"debía lanzar ValueError con ({c}, {a}) y devolvió {v}"
        return True, ""

    for nombre, fn in (
        ("identidad_secuencia/par del capítulo", id_puntual),
        ("identidad_secuencia/extremos", id_extremos),
        ("identidad_secuencia/huecos", id_huecos),
        ("identidad_secuencia/longitudes distintas", id_longitudes),
        ("zona_de_fiabilidad/umbrales", zonas),
        ("probabilidad_metropolis/traza del capítulo", metro_puntual),
        ("probabilidad_metropolis/movimiento que no empeora", metro_mejora),
        ("probabilidad_metropolis/monotonía en T", metro_monotona),
        ("probabilidad_metropolis/guarda del parámetro", metro_guarda),
        ("clashscore/traza del capítulo", clash_puntual),
        ("clashscore/normalización por 1000", clash_escala),
        ("clashscore/guarda de dominio", clash_guarda),
    ):
        prueba(nombre, fn)

    if fallos:
        for f in fallos:
            print(f"FALLO: {f}")
        print("PREDICCION_INCOMPLETA")
        return 1
    print("PREDICCION_OK: las cuatro funciones cumplen el contrato (12 comprobaciones)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
