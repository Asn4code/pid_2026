#!/usr/bin/env python3
"""Prueba el módulo de control de calidad del alumnado."""
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
        print("uso: comprobar_calidad.py RUTA_DEL_MODULO", file=sys.stderr); return 2
    ruta = Path(sys.argv[1])
    if not ruta.is_file():
        print(f"FALTA: no existe {ruta}"); print("MODULO_INCOMPLETO"); return 1
    try:
        m = cargar(ruta)
    except Exception as e:
        print(f"FALLO: no se puede importar: {type(e).__name__}: {e}"); print("MODULO_INCOMPLETO"); return 1
    req = ("puntuacion", "media_calidad", "recortar")
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

    def p_puntuacion():
        for c, esp in (("!", 0), ("#", 2), ("5", 20), ("?", 30), ("I", 40)):
            v = int(m.puntuacion(c))
            assert v == esp, f"el carácter {c!r} vale {esp} y su módulo dice {v}"

    def p_guarda():
        for malo in (" ", "\t", ""):
            try:
                m.puntuacion(malo)
            except ValueError:
                continue
            raise AssertionError(f"acepta {malo!r}, que no es un carácter de calidad válido")

    def p_media():
        assert abs(float(m.media_calidad("IIII")) - 40.0) < 1e-9, "la media de cuatro calidades máximas no es 40"
        assert abs(float(m.media_calidad("II!!")) - 20.0) < 1e-9, "la media de dos máximas y dos mínimas no es 20"

    def p_recorte_amortigua():
        # la ventana promedia y por eso un cero aislado no corta la lectura
        aislado = "IIIII!IIIII"
        c4 = int(m.recortar(aislado, 4, 20.0))
        c1 = int(m.recortar(aislado, 1, 20.0))
        assert c4 == len(aislado), f"con una sola base mala en medio, la ventana de 4 no debe cortar y su módulo corta en {c4}"
        assert c1 < c4, "con ventana 1, una sola base mala sí corta: es la diferencia que justifica la ventana"
        caida = "IIIIII!!!!"
        assert int(m.recortar(caida, 4, 20.0)) == 5, "sobre una caída sostenida, la ventana de 4 corta en la posición 5"

    def p_recorte_extremos():
        assert int(m.recortar("IIIIIIIIII", 4, 20.0)) == 10, "una lectura entera de calidad máxima no debe recortarse"
        assert int(m.recortar("!!!!!!!!!!", 4, 20.0)) == 0, "una lectura entera de calidad mínima debe quedar vacía"

    prueba("la conversión de carácter a puntuación es correcta", p_puntuacion)
    prueba("los caracteres por debajo del rango se rechazan", p_guarda)
    prueba("la media de una cadena de calidades es correcta", p_media)
    prueba("el recorte por ventana amortigua y corta donde debe", p_recorte_amortigua)
    prueba("los dos extremos, todo bueno y todo malo, se tratan bien", p_recorte_extremos)

    if fallos:
        print(f"MODULO_INCOMPLETO: {len(fallos)} propiedades sin cumplir"); return 1
    print("MODULO_OK: el módulo de control de calidad cumple su contrato"); return 0


if __name__ == "__main__":
    raise SystemExit(main())
