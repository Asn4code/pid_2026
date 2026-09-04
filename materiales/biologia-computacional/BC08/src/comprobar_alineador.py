#!/usr/bin/env python3
"""Prueba el índice y el alineador del alumnado."""
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
        print("uso: comprobar_alineador.py RUTA_DEL_MODULO", file=sys.stderr); return 2
    ruta = Path(sys.argv[1])
    if not ruta.is_file():
        print(f"FALTA: no existe {ruta}"); print("MODULO_INCOMPLETO"); return 1
    try:
        m = cargar(ruta)
    except Exception as e:
        print(f"FALLO: no se puede importar: {type(e).__name__}: {e}"); print("MODULO_INCOMPLETO"); return 1
    req = ("construir_indice", "localizar")
    faltan = [n for n in req if not callable(getattr(m, n, None))]
    if faltan:
        print(f"FALTA: funciones no definidas: {', '.join(faltan)}"); print("MODULO_INCOMPLETO"); return 1

    fallos = []
    def prueba(nombre, fn):
        try:
            fn(); print(f"OK: {nombre}")
        except AssertionError as e:
            print(f"FALLO: {nombre}: {e}"); fallos.append(nombre)
        except Exception as e:
            print(f"FALLO: {nombre}: {type(e).__name__}: {e}"); fallos.append(nombre)

    def p_indice():
        g = "ACGTACGTAA"
        idx = m.construir_indice(g, 3)
        assert isinstance(idx, dict), "el índice debe ser un diccionario"
        assert len(idx) == 5, f"sobre {g} con k=3 hay 5 tripletes distintos y su índice tiene {len(idx)}"
        assert sorted(idx["ACG"]) == [1, 5], f"ACG aparece en las posiciones 1 y 5 y su índice dice {idx.get('ACG')}"
        assert sum(len(v) for v in idx.values()) == len(g) - 3 + 1, "el total de posiciones no cuadra con el número de ventanas"

    def p_indice_desde_uno():
        idx = m.construir_indice("AAAT", 3)
        assert idx["AAA"] == [1], f"la numeración debe empezar en 1 y su índice dice {idx.get('AAA')}"

    def p_localizar_unico():
        g = "CATGGTCAATGGCTA"
        r = m.localizar(g, "TCAAT", 3)
        assert r == [6], f"la lectura TCAAT solo encaja en la posición 6 y su módulo dice {r}"

    def p_localizar_ambiguo():
        g = "CATGGTCAATGGCTA"
        r = m.localizar(g, "TGG", 3)
        assert sorted(r) == [3, 10], f"la lectura TGG encaja en 3 y en 10, y su módulo dice {r}"

    def p_localizar_ausente():
        g = "CATGGTCAATGGCTA"
        r = m.localizar(g, "GGGG", 3)
        assert r == [], f"una lectura que no está debe devolver la lista vacía, y su módulo dice {r}"

    def p_guarda():
        for g, k in (("TG", 3), ("ACGT", 0), ("", 3)):
            try:
                m.construir_indice(g, k)
            except ValueError:
                continue
            raise AssertionError(f"acepta un caso imposible: genoma {g!r} con k={k}")

    prueba("el índice agrupa las posiciones de cada k-mero", p_indice)
    prueba("las posiciones se numeran desde 1", p_indice_desde_uno)
    prueba("una lectura sin repeticiones se localiza en un solo sitio", p_localizar_unico)
    prueba("una lectura ambigua devuelve todas sus posiciones", p_localizar_ambiguo)
    prueba("una lectura ausente devuelve la lista vacía y no falla", p_localizar_ausente)
    prueba("un genoma más corto que k, o un k no positivo, se rechazan", p_guarda)

    if fallos:
        print(f"MODULO_INCOMPLETO: {len(fallos)} propiedades sin cumplir"); return 1
    print("MODULO_OK: el índice y el alineador cumplen su contrato"); return 0


if __name__ == "__main__":
    raise SystemExit(main())
