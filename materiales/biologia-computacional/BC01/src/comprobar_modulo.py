#!/usr/bin/env python3
"""Prueba el módulo de secuencias del alumnado contra cinco propiedades.

Uso: comprobar_modulo.py RUTA_DEL_MODULO
No compara con valores impresos en el enunciado: comprueba relaciones que
cualquier implementación correcta cumple, con secuencias que no aparecen en el
capítulo. Imprime una línea por propiedad y termina en MODULO_OK o
MODULO_INCOMPLETO.
"""
from __future__ import annotations

import importlib.util
import sys
from pathlib import Path

SECRETAS = ["GGCATTACGATCCGTTA", "AATTCCGGAATTCCGGA", "CGCGCGATATCGCGCGT", "TTTTAAAACCCCGGGGA"]
REQUERIDAS = ("validar_adn", "contenido_gc", "complemento_reverso", "transcribir", "perfil_gc")


def cargar(ruta: Path):
    spec = importlib.util.spec_from_file_location("modulo_alumno", ruta)
    if spec is None or spec.loader is None:
        raise ImportError(f"no se puede cargar {ruta}")
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def gc_ref(s: str) -> float:
    return (sum(1 for b in s if b in "GC") / len(s)) * 100.0


def main() -> int:
    if len(sys.argv) != 2:
        print("uso: comprobar_modulo.py RUTA_DEL_MODULO", file=sys.stderr)
        return 2
    ruta = Path(sys.argv[1])
    if not ruta.is_file():
        print(f"FALTA: no existe {ruta}")
        print("MODULO_INCOMPLETO")
        return 1
    try:
        m = cargar(ruta)
    except Exception as e:
        print(f"FALLO: el módulo no se puede importar: {type(e).__name__}: {e}")
        print("MODULO_INCOMPLETO")
        return 1

    fallos = []
    faltan = [n for n in REQUERIDAS if not callable(getattr(m, n, None))]
    if faltan:
        print(f"FALTA: funciones no definidas: {', '.join(faltan)}")
        print("MODULO_INCOMPLETO")
        return 1

    def prueba(nombre, fn):
        try:
            fn()
            print(f"OK: {nombre}")
        except AssertionError as e:
            print(f"FALLO: {nombre}: {e}")
            fallos.append(nombre)
        except Exception as e:
            print(f"FALLO: {nombre}: {type(e).__name__}: {e}")
            fallos.append(nombre)

    def p1():
        for s in SECRETAS:
            assert m.complemento_reverso(m.complemento_reverso(s)) == s, f"aplicado dos veces no devuelve {s}"

    def p2():
        for s in SECRETAS:
            a, b = m.contenido_gc(s), m.contenido_gc(m.complemento_reverso(s))
            assert abs(a - b) < 1e-9, f"GC de {s} y de su complemento reverso difieren"
            assert abs(a - gc_ref(s)) < 1e-9, f"GC de {s} no coincide con el recuento directo"

    def p3():
        for s in SECRETAS:
            r = m.transcribir(s)
            assert len(r) == len(s), "la transcripción cambia la longitud"
            assert "T" not in r and r.count("U") == s.count("T"), "la transcripción no sustituye todas las T por U"

    def p4():
        s = SECRETAS[0]
        for ventana, paso in ((4, 1), (5, 2), (6, 3)):
            perfil = m.perfil_gc(s, ventana, paso)
            esperadas = len(range(0, len(s) - ventana + 1, paso))
            assert len(perfil) == esperadas, f"con ventana {ventana} y paso {paso} se esperan {esperadas} ventanas y hay {len(perfil)}"
            assert abs(float(perfil[0]) - gc_ref(s[:ventana])) < 1e-9, "la primera ventana no coincide con el GC de las primeras bases"

    def p5():
        for malo in ("ATGCN", "AUGC", "ATG CA", ""):
            try:
                m.validar_adn(malo)
            except ValueError:
                continue
            raise AssertionError(f"la guarda acepta {malo!r}, que no es ADN")
        assert m.validar_adn(" atgcgatc ") == "ATGCGATC", "la guarda no normaliza espacios y minúsculas"

    prueba("complemento reverso aplicado dos veces devuelve el original", p1)
    prueba("el contenido GC coincide con el recuento directo y con el de la hebra complementaria", p2)
    prueba("la transcripción conserva la longitud y no deja timinas", p3)
    prueba("el perfil devuelve el número de ventanas que impone el paso", p4)
    prueba("la guarda rechaza N, U, espacios interiores y la cadena vacía, y normaliza", p5)

    if fallos:
        print(f"MODULO_INCOMPLETO: {len(fallos)} propiedades sin cumplir")
        return 1
    print("MODULO_OK: las cinco propiedades se cumplen")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
