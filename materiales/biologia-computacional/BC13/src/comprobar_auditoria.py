#!/usr/bin/env python3
"""Prueba el módulo de auditoría del alumnado contra su contrato."""
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


def main() -> int:
    if len(sys.argv) != 2:
        print("uso: comprobar_auditoria.py RUTA_DEL_MODULO", file=sys.stderr)
        return 2
    ruta = Path(sys.argv[1])
    if not ruta.is_file():
        print(f"FALTA: no existe {ruta}")
        print("AUDITORIA_INCOMPLETA")
        return 1
    try:
        m = cargar(ruta)
    except Exception as e:
        print(f"FALLO: no se puede importar: {type(e).__name__}: {e}")
        print("AUDITORIA_INCOMPLETA")
        return 1

    req = ("banda_plddt", "plddt_medio", "dictamen_pae", "desigualdad_triangular")
    faltan = [n for n in req if not callable(getattr(m, n, None))]
    if faltan:
        print(f"FALTA: funciones no definidas: {', '.join(faltan)}")
        print("AUDITORIA_INCOMPLETA")
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

    # banda_plddt: las tres fronteras y el interior de cada banda
    def bandas():
        casos = ((100.0, "muy_alta"), (92.5, "muy_alta"), (90.0, "muy_alta"),
                 (89.9, "alta"), (75.0, "alta"), (70.0, "alta"),
                 (69.9, "baja"), (55.0, "baja"), (50.0, "baja"),
                 (49.9, "muy_baja"), (0.0, "muy_baja"))
        malos = [(v, e, m.banda_plddt(v)) for v, e in casos if m.banda_plddt(v) != e]
        return not malos, "; ".join(f"{v} esperaba {e} y devolvió {o}" for v, e, o in malos)

    def banda_guarda():
        for v in (-0.1, 100.1):
            try:
                r = m.banda_plddt(v)
            except ValueError:
                continue
            return False, f"debía lanzar ValueError con {v} y devolvió {r}"
        return True, ""

    # plddt_medio
    def medio_puntual():
        v = m.plddt_medio([95.0, 92.0, 88.0, 45.0])
        return cerca(v, 80.0), f"esperado 80.0, obtenido {v}"

    def medio_vacia():
        try:
            v = m.plddt_medio([])
        except ValueError:
            return True, ""
        return False, f"debía rechazar la lista vacía y devolvió {v}"

    def medio_fuera_de_rango():
        try:
            v = m.plddt_medio([95.0, 120.0])
        except ValueError:
            return True, ""
        return False, f"debía rechazar un valor fuera de [0, 100] y devolvió {v}"

    # dictamen_pae
    def pae_puntual():
        media, estado = m.dictamen_pae([[2.5, 3.0], [3.0, 2.8]])
        return (cerca(media, 2.825) and estado == "rigida"), f"esperado (2.825, rigida), obtenido ({media}, {estado})"

    def pae_fronteras():
        casos = (([[4.99]], "rigida"), ([[5.0]], "intermedia"), ([[15.0]], "intermedia"), ([[15.01]], "flexible"))
        malos = [(mt, e, m.dictamen_pae(mt)[1]) for mt, e in casos if m.dictamen_pae(mt)[1] != e]
        return not malos, "; ".join(f"{mt} esperaba {e} y devolvió {o}" for mt, e, o in malos)

    def pae_no_rectangular():
        try:
            v = m.dictamen_pae([[1.0, 2.0], [3.0]])
        except ValueError:
            return True, ""
        return False, f"debía rechazar la matriz no rectangular y devolvió {v}"

    def pae_vacia():
        try:
            v = m.dictamen_pae([])
        except ValueError:
            return True, ""
        return False, f"debía rechazar la matriz vacía y devolvió {v}"

    # desigualdad_triangular
    def triangulo_valido():
        return m.desigualdad_triangular(3.0, 4.0, 5.0) is True, "el triángulo 3-4-5 es consistente"

    def triangulo_invalido():
        # el lado largo excede la suma de los otros dos: geometría imposible
        return m.desigualdad_triangular(1.0, 1.0, 5.0) is False, "1-1-5 no puede realizarse en el espacio euclídeo"

    def triangulo_degenerado():
        # tres puntos alineados siguen siendo realizables
        return m.desigualdad_triangular(2.0, 3.0, 5.0) is True, "el caso degenerado 2-3-5 sí es realizable"

    def triangulo_guarda():
        try:
            v = m.desigualdad_triangular(-1.0, 2.0, 3.0)
        except ValueError:
            return True, ""
        return False, f"debía lanzar ValueError con una distancia negativa y devolvió {v}"

    for nombre, fn in (
        ("banda_plddt/las cuatro bandas", bandas),
        ("banda_plddt/guarda de rango", banda_guarda),
        ("plddt_medio/traza del capítulo", medio_puntual),
        ("plddt_medio/lista vacía", medio_vacia),
        ("plddt_medio/valor fuera de rango", medio_fuera_de_rango),
        ("dictamen_pae/traza del capítulo", pae_puntual),
        ("dictamen_pae/fronteras", pae_fronteras),
        ("dictamen_pae/matriz no rectangular", pae_no_rectangular),
        ("dictamen_pae/matriz vacía", pae_vacia),
        ("desigualdad_triangular/caso válido", triangulo_valido),
        ("desigualdad_triangular/caso imposible", triangulo_invalido),
        ("desigualdad_triangular/caso degenerado", triangulo_degenerado),
        ("desigualdad_triangular/guarda de dominio", triangulo_guarda),
    ):
        prueba(nombre, fn)

    if fallos:
        for f in fallos:
            print(f"FALLO: {f}")
        print("AUDITORIA_INCOMPLETA")
        return 1
    print("AUDITORIA_OK: las cuatro funciones cumplen el contrato (13 comprobaciones)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
