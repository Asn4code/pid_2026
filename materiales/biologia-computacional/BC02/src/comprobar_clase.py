#!/usr/bin/env python3
"""Prueba la clase Proteina del alumnado contra su contrato.

Uso: comprobar_clase.py RUTA_DEL_MODULO
No compara con los valores del enunciado: comprueba propiedades y relaciones
sobre péptidos que no aparecen impresos en ningún sitio.
"""
from __future__ import annotations

import importlib.util
import sys
from pathlib import Path

MASAS = {"G": 57.05, "A": 71.08, "S": 87.08, "P": 97.12, "V": 99.13, "T": 101.11,
         "C": 103.14, "L": 113.16, "I": 113.16, "N": 114.10, "D": 115.09, "Q": 128.13,
         "K": 128.17, "E": 129.12, "M": 131.20, "H": 137.14, "F": 147.18, "R": 156.19,
         "Y": 163.18, "W": 186.21}
AGUA = 18.015
HIDRO = {"I": 4.5, "V": 4.2, "L": 3.8, "F": 2.8, "C": 2.5, "M": 1.9, "A": 1.8, "G": -0.4,
         "T": -0.7, "S": -0.8, "W": -0.9, "Y": -1.3, "P": -1.6, "H": -3.2, "E": -3.5,
         "Q": -3.5, "D": -3.5, "N": -3.5, "K": -3.9, "R": -4.5}
SECRETOS = ["WYFGA", "KRDEN", "LIVAM", "TSCPG"]


def cargar(ruta: Path):
    spec = importlib.util.spec_from_file_location("modulo_alumno", ruta)
    if spec is None or spec.loader is None:
        raise ImportError(f"no se puede cargar {ruta}")
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def main() -> int:
    if len(sys.argv) != 2:
        print("uso: comprobar_clase.py RUTA_DEL_MODULO", file=sys.stderr)
        return 2
    ruta = Path(sys.argv[1])
    if not ruta.is_file():
        print(f"FALTA: no existe {ruta}"); print("CLASE_INCOMPLETA"); return 1
    try:
        m = cargar(ruta)
    except Exception as e:
        print(f"FALLO: el módulo no se puede importar: {type(e).__name__}: {e}")
        print("CLASE_INCOMPLETA"); return 1
    P = getattr(m, "Proteina", None)
    if P is None:
        print("FALTA: el módulo no define una clase llamada Proteina")
        print("CLASE_INCOMPLETA"); return 1

    fallos = []

    def prueba(nombre, fn):
        try:
            fn(); print(f"OK: {nombre}")
        except AssertionError as e:
            print(f"FALLO: {nombre}: {e}"); fallos.append(nombre)
        except Exception as e:
            print(f"FALLO: {nombre}: {type(e).__name__}: {e}"); fallos.append(nombre)

    def p_masa():
        for s in SECRETOS:
            esperada = sum(MASAS[c] for c in s) + AGUA
            obtenida = float(P(s).masa())
            assert abs(obtenida - esperada) < 0.01, f"para {s} da {obtenida:.3f} y la suma de residuos más un agua da {esperada:.3f}"

    def p_agua():
        corta, larga = P("AA"), P("AAAA")
        d = float(larga.masa()) - float(corta.masa())
        assert abs(d - 2 * MASAS["A"]) < 0.01, "al alargar el péptido se está sumando más de un agua"

    def p_composicion():
        c = P("LIVAM").composicion()
        assert dict(c) == {"L": 1, "I": 1, "V": 1, "A": 1, "M": 1}, f"composición inesperada: {dict(c)}"
        c2 = dict(P("AAKKA").composicion())
        assert c2.get("A") == 3 and c2.get("K") == 2, f"no cuenta bien los repetidos: {c2}"

    def p_hidropatia():
        for s in SECRETOS:
            esperada = sum(HIDRO[c] for c in s) / len(s)
            obtenida = float(P(s).hidropatia_media())
            assert abs(obtenida - esperada) < 0.001, f"para {s} da {obtenida:.3f} y la media de la escala da {esperada:.3f}"

    def p_perfil():
        s = "WYFGAKRDEN"
        perfil = list(P(s).perfil_hidropatia(3))
        assert len(perfil) == len(s) - 2, f"con ventana 3 sobre {len(s)} residuos se esperan {len(s)-2} ventanas y hay {len(perfil)}"
        prim = float(perfil[0][-1] if isinstance(perfil[0], (list, tuple)) else perfil[0])
        esperada = sum(HIDRO[c] for c in s[:3]) / 3
        assert abs(prim - esperada) < 0.001, "la primera ventana no coincide con la media de los tres primeros residuos"

    def p_guarda():
        for malo in ("MKVX", "MK VL", "mkv1", ""):
            try:
                P(malo)
            except ValueError:
                continue
            raise AssertionError(f"el constructor acepta {malo!r}, que no es un péptido válido")
        assert P("  mkvlm  ").secuencia == "MKVLM", "el constructor no normaliza espacios y minúsculas en el atributo secuencia"

    prueba("la masa suma los residuos y un solo agua", p_masa)
    prueba("alargar el péptido no añade aguas de más", p_agua)
    prueba("la composición cuenta bien, incluidos los residuos repetidos", p_composicion)
    prueba("la hidropatía media coincide con la escala", p_hidropatia)
    prueba("el perfil devuelve las ventanas que corresponden y empieza bien", p_perfil)
    prueba("el constructor rechaza lo que no es un péptido y normaliza lo que sí", p_guarda)

    if fallos:
        print(f"CLASE_INCOMPLETA: {len(fallos)} propiedades sin cumplir"); return 1
    print("CLASE_OK: la clase cumple su contrato"); return 0


if __name__ == "__main__":
    raise SystemExit(main())
