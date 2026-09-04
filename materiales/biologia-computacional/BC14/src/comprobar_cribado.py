#!/usr/bin/env python3
"""Prueba el módulo de cribado del alumnado contra su contrato."""
from __future__ import annotations

import importlib.util
import math
import sys
from pathlib import Path

R_GAS_KCAL = 1.987204e-3


def cargar(ruta: Path):
    spec = importlib.util.spec_from_file_location("modulo_alumno", ruta)
    if spec is None or spec.loader is None:
        raise ImportError(f"no se puede cargar {ruta}")
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def main() -> int:
    if len(sys.argv) != 2:
        print("uso: comprobar_cribado.py RUTA_DEL_MODULO", file=sys.stderr)
        return 2
    ruta = Path(sys.argv[1])
    if not ruta.is_file():
        print(f"FALTA: no existe {ruta}")
        print("CRIBADO_INCOMPLETO")
        return 1
    try:
        m = cargar(ruta)
    except Exception as e:
        print(f"FALLO: no se puede importar: {type(e).__name__}: {e}")
        print("CRIBADO_INCOMPLETO")
        return 1

    req = ("velocity_verlet_step", "kd_ilustrativa_um", "tanimoto", "violaciones_ro5")
    faltan = [n for n in req if not callable(getattr(m, n, None))]
    if faltan:
        print(f"FALTA: funciones no definidas: {', '.join(faltan)}")
        print("CRIBADO_INCOMPLETO")
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

    # velocity_verlet_step: el paso completo, no solo la posicion
    def verlet_traza():
        x1, v1 = m.velocity_verlet_step(0.0, 1.0, 2.0, 2.0, 0.5)
        return (cerca(x1, 0.75) and cerca(v1, 2.0)), f"esperado (0.75, 2.0), obtenido ({x1}, {v1})"

    def verlet_velocidad():
        # con a1 distinta de a0 la velocidad usa el promedio de ambas
        x1, v1 = m.velocity_verlet_step(0.0, 0.0, 0.0, 4.0, 1.0)
        return (cerca(x1, 0.0) and cerca(v1, 2.0)), f"la velocidad promedia a0 y a1: esperado (0.0, 2.0), obtenido ({x1}, {v1})"

    def verlet_guarda():
        for dt in (0.0, -1.0):
            try:
                r = m.velocity_verlet_step(0.0, 1.0, 2.0, 2.0, dt)
            except ValueError:
                continue
            return False, f"debía lanzar ValueError con dt={dt} y devolvió {r}"
        return True, ""

    # kd_ilustrativa_um
    def kd_traza():
        v = m.kd_ilustrativa_um(-8.50, 298.15)
        esperado = math.exp(-8.50 / (R_GAS_KCAL * 298.15)) * 1.0e6
        return cerca(v, esperado, 1e-3), f"esperado {esperado:.6f}, obtenido {v}"

    def kd_monotona():
        # mas negativo es menor constante de disociacion
        a = m.kd_ilustrativa_um(-10.0, 298.15)
        b = m.kd_ilustrativa_um(-6.0, 298.15)
        return a < b, f"un valor más negativo debe dar menor Kd: {a} frente a {b}"

    def kd_guarda():
        for t in (0.0, -5.0):
            try:
                v = m.kd_ilustrativa_um(-8.50, t)
            except ValueError:
                continue
            return False, f"debía lanzar ValueError con T={t} y devolvió {v}"
        return True, ""

    # tanimoto
    def tan_traza():
        v = m.tanimoto(10, 12, 8)
        return cerca(v, 8 / 14), f"esperado {8/14:.6f}, obtenido {v}"

    def tan_extremos():
        a = m.tanimoto(10, 10, 10)
        b = m.tanimoto(10, 12, 0)
        return (cerca(a, 1.0) and cerca(b, 0.0)), f"esperado 1.0 y 0.0, obtenido {a} y {b}"

    def tan_vacias():
        # dos huellas sin ningun bit activo se consideran identicas
        v = m.tanimoto(0, 0, 0)
        return cerca(v, 1.0), f"esperado 1.0 para dos huellas vacías, obtenido {v}"

    def tan_guarda():
        for args in ((-1, 5, 0), (5, 10, 7)):
            try:
                v = m.tanimoto(*args)
            except ValueError:
                continue
            return False, f"debía lanzar ValueError con {args} y devolvió {v}"
        return True, ""

    # violaciones_ro5
    def ro5_traza():
        r = m.violaciones_ro5(350.0, 2.50, 2, 4)
        return (r["violaciones"] == 0 and r["riesgo_absorcion"] == "bajo"), f"esperado 0 violaciones y riesgo bajo, obtenido {r}"

    def ro5_fronteras():
        # los criterios son 'no mayor que': el valor limite no viola
        casos = ((500.0, 5.0, 5, 10, 0), (500.1, 5.0, 5, 10, 1), (500.0, 5.1, 5, 10, 1),
                 (500.0, 5.0, 6, 10, 1), (500.0, 5.0, 5, 11, 1))
        malos = [(c, c[4], m.violaciones_ro5(*c[:4])["violaciones"]) for c in casos
                 if m.violaciones_ro5(*c[:4])["violaciones"] != c[4]]
        return not malos, "; ".join(f"{c[:4]} esperaba {e} y devolvió {o}" for c, e, o in malos)

    def ro5_riesgo():
        bajo = m.violaciones_ro5(520.0, 2.0, 2, 4)
        alto = m.violaciones_ro5(520.0, 5.5, 2, 4)
        return (bajo["riesgo_absorcion"] == "bajo" and alto["riesgo_absorcion"] == "alto"), \
            f"una violación es riesgo bajo y dos es alto: obtenido {bajo} y {alto}"

    for nombre, fn in (
        ("velocity_verlet_step/traza del capítulo", verlet_traza),
        ("velocity_verlet_step/promedio de aceleraciones", verlet_velocidad),
        ("velocity_verlet_step/guarda del paso", verlet_guarda),
        ("kd_ilustrativa_um/traza del capítulo", kd_traza),
        ("kd_ilustrativa_um/monotonía", kd_monotona),
        ("kd_ilustrativa_um/guarda de temperatura", kd_guarda),
        ("tanimoto/traza del capítulo", tan_traza),
        ("tanimoto/extremos", tan_extremos),
        ("tanimoto/huellas vacías", tan_vacias),
        ("tanimoto/guardas de dominio", tan_guarda),
        ("violaciones_ro5/traza del capítulo", ro5_traza),
        ("violaciones_ro5/fronteras", ro5_fronteras),
        ("violaciones_ro5/etiqueta de riesgo", ro5_riesgo),
    ):
        prueba(nombre, fn)

    if fallos:
        for f in fallos:
            print(f"FALLO: {f}")
        print("CRIBADO_INCOMPLETO")
        return 1
    print("CRIBADO_OK: las cuatro funciones cumplen el contrato (13 comprobaciones)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
