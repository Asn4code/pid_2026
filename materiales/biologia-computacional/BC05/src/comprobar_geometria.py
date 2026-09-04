#!/usr/bin/env python3
"""Prueba el módulo de geometría estructural del alumnado.

Uso: comprobar_geometria.py RUTA_DEL_MODULO
Comprueba propiedades geométricas sobre coordenadas que el enunciado no muestra.
"""
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
        print("uso: comprobar_geometria.py RUTA_DEL_MODULO", file=sys.stderr)
        return 2
    ruta = Path(sys.argv[1])
    if not ruta.is_file():
        print(f"FALTA: no existe {ruta}"); print("MODULO_INCOMPLETO"); return 1
    try:
        m = cargar(ruta)
    except Exception as e:
        print(f"FALLO: el módulo no se puede importar: {type(e).__name__}: {e}")
        print("MODULO_INCOMPLETO"); return 1
    requeridas = ("distancia", "centroide", "mapa_contactos")
    faltan = [n for n in requeridas if not callable(getattr(m, n, None))]
    if faltan:
        print(f"FALTA: funciones no definidas: {', '.join(faltan)}")
        print("MODULO_INCOMPLETA".replace("A", "O")); return 1

    fallos = []
    def prueba(nombre, fn):
        try:
            fn(); print(f"OK: {nombre}")
        except AssertionError as e:
            print(f"FALLO: {nombre}: {e}"); fallos.append(nombre)
        except Exception as e:
            print(f"FALLO: {nombre}: {type(e).__name__}: {e}"); fallos.append(nombre)

    def p_distancia():
        casos = [((0,0,0),(3,4,0),5.0), ((1,1,1),(1,1,1),0.0), ((-2,0,0),(2,0,0),4.0),
                 ((1,2,3),(4,6,3),5.0)]
        for a,b,esp in casos:
            d=float(m.distancia(a,b))
            assert abs(d-esp)<1e-9, f"entre {a} y {b} da {d} y debería dar {esp}"
        assert abs(float(m.distancia((1,2,3),(4,6,3))) - float(m.distancia((4,6,3),(1,2,3)))) < 1e-12, \
            "la distancia no es simétrica"

    def p_centroide():
        c = tuple(float(v) for v in m.centroide([(0,0,0),(2,0,0),(0,2,0),(2,2,0)]))
        assert all(abs(a-b)<1e-9 for a,b in zip(c,(1.0,1.0,0.0))), f"el centroide de un cuadrado no es su centro: {c}"
        c2 = tuple(float(v) for v in m.centroide([(5,5,5)]))
        assert all(abs(a-b)<1e-9 for a,b in zip(c2,(5.0,5.0,5.0))), "el centroide de un solo punto debe ser ese punto"

    def p_contactos():
        puntos=[(0,0,0),(3,0,0),(20,0,0)]
        n8=m.mapa_contactos(puntos, 8.0)
        n2=m.mapa_contactos(puntos, 2.0)
        c8 = n8 if isinstance(n8,int) else len(n8)
        c2 = n2 if isinstance(n2,int) else len(n2)
        assert c8 == 1, f"con umbral 8 hay un solo par en contacto y su módulo dice {c8}"
        assert c2 == 0, f"con umbral 2 no hay ningún par en contacto y su módulo dice {c2}"
        assert c8 >= c2, "subir el umbral no puede reducir el número de contactos"

    prueba("la distancia es correcta y simétrica", p_distancia)
    prueba("el centroide es la media de las coordenadas", p_centroide)
    prueba("el mapa de contactos depende del umbral en el sentido correcto", p_contactos)

    if fallos:
        print(f"MODULO_INCOMPLETO: {len(fallos)} propiedades sin cumplir"); return 1
    print("MODULO_OK: el módulo de geometría cumple su contrato"); return 0


if __name__ == "__main__":
    raise SystemExit(main())
