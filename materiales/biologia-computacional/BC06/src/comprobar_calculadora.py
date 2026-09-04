#!/usr/bin/env python3
"""Prueba la calculadora de dimensionamiento del alumnado.

Uso: comprobar_calculadora.py RUTA_DEL_MODULO
Comprueba relaciones, no valores memorizables.
"""
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
        print("uso: comprobar_calculadora.py RUTA_DEL_MODULO", file=sys.stderr); return 2
    ruta = Path(sys.argv[1])
    if not ruta.is_file():
        print(f"FALTA: no existe {ruta}"); print("CALCULADORA_INCOMPLETA"); return 1
    try:
        m = cargar(ruta)
    except Exception as e:
        print(f"FALLO: no se puede importar: {type(e).__name__}: {e}"); print("CALCULADORA_INCOMPLETA"); return 1
    req = ("cobertura", "lecturas_necesarias", "fraccion_sin_cubrir")
    faltan = [n for n in req if not callable(getattr(m, n, None))]
    if faltan:
        print(f"FALTA: funciones no definidas: {', '.join(faltan)}"); print("CALCULADORA_INCOMPLETA"); return 1

    fallos = []
    def prueba(nombre, fn):
        try:
            fn(); print(f"OK: {nombre}")
        except AssertionError as e:
            print(f"FALLO: {nombre}: {e}"); fallos.append(nombre)
        except Exception as e:
            print(f"FALLO: {nombre}: {type(e).__name__}: {e}"); fallos.append(nombre)

    def p_cobertura():
        for lecturas, longitud, genoma in ((1000, 100, 50_000), (7, 250, 875), (12345, 76, 1_000_000)):
            esperada = lecturas * longitud / genoma
            obtenida = float(m.cobertura(lecturas, longitud, genoma))
            assert abs(obtenida - esperada) < 1e-9, f"con {lecturas} lecturas de {longitud} sobre {genoma} da {obtenida} y debería dar {esperada}"

    def p_ida_y_vuelta():
        for objetivo, longitud, genoma in ((30.0, 150, 4_600_000), (5.0, 100, 20_000)):
            n = m.lecturas_necesarias(objetivo, longitud, genoma)
            c = float(m.cobertura(n, longitud, genoma))
            assert c >= objetivo - 1e-6, f"con {n} lecturas la cobertura sale {c:.3f} y no alcanza el objetivo {objetivo}"
            assert c < objetivo + 1.0, f"con {n} lecturas la cobertura se pasa de largo: {c:.3f} frente a {objetivo}"

    def p_monotonia():
        a = float(m.cobertura(100, 150, 3000))
        b = float(m.cobertura(200, 150, 3000))
        assert b > a, "duplicar el número de lecturas debe aumentar la cobertura"
        c = float(m.cobertura(100, 150, 6000))
        assert c < a, "duplicar el tamaño del genoma debe reducir la cobertura"

    def p_huecos():
        import math
        for cob in (1.0, 5.0, 30.0):
            esperada = math.exp(-cob)
            obtenida = float(m.fraccion_sin_cubrir(cob))
            assert abs(obtenida - esperada) < 1e-9, f"con cobertura {cob} da {obtenida:.8f} y el modelo da {esperada:.8f}"
        assert float(m.fraccion_sin_cubrir(30.0)) < float(m.fraccion_sin_cubrir(5.0)), \
            "más cobertura tiene que dejar menos genoma sin cubrir"

    def p_guarda():
        for mala in ((0, 150, 3000), (100, 0, 3000), (100, 150, 0), (-1, 150, 3000)):
            try:
                m.cobertura(*mala)
            except ValueError:
                continue
            raise AssertionError(f"acepta parámetros sin sentido físico: {mala}")

    prueba("la cobertura es lecturas por longitud entre tamaño del genoma", p_cobertura)
    prueba("las lecturas necesarias devuelven justo la cobertura pedida", p_ida_y_vuelta)
    prueba("la cobertura crece con las lecturas y baja con el tamaño del genoma", p_monotonia)
    prueba("la fracción sin cubrir sigue el modelo de Poisson", p_huecos)
    prueba("los parámetros nulos o negativos se rechazan", p_guarda)

    if fallos:
        print(f"CALCULADORA_INCOMPLETA: {len(fallos)} propiedades sin cumplir"); return 1
    print("CALCULADORA_OK: la calculadora cumple su contrato"); return 0


if __name__ == "__main__":
    raise SystemExit(main())
