#!/usr/bin/env python3
"""Prueba el procesador de estructuras del alumnado contra su contrato.

Uso: comprobar_procesador.py RUTA_DEL_GUION
Ejecuta el guion sobre ficheros que el enunciado no muestra, incluidos casos con
líneas mal formadas y con átomos que no pertenecen a la proteína.
"""
from __future__ import annotations

import subprocess
import sys
import tempfile
from pathlib import Path


def atom(i, nombre, res, resid, x, y, z, b):
    return (f"ATOM  {i:>5} {nombre:^4}{res:>3} A{resid:>4}    "
            f"{x:>8.3f}{y:>8.3f}{z:>8.3f}  1.00{b:>6.2f}           C")


def escribe(ruta: Path, atomos, extras=()):
    lineas = ["HEADER    PRUEBA"]
    lineas += [atom(*a) for a in atomos]
    lineas += list(extras)
    lineas.append("END")
    ruta.write_text("\n".join(lineas) + "\n", encoding="utf-8")


def corre(guion: Path, pdb: Path):
    r = subprocess.run(["python3", str(guion), str(pdb)], capture_output=True, text=True, timeout=60)
    return r.returncode, r.stdout + r.stderr


def main() -> int:
    if len(sys.argv) != 2:
        print("uso: comprobar_procesador.py RUTA_DEL_GUION", file=sys.stderr)
        return 2
    guion = Path(sys.argv[1])
    if not guion.is_file():
        print(f"FALTA: no existe {guion}"); print("PROCESADOR_INCOMPLETO"); return 1
    fallos = []
    def ko(m): print(f"FALLO: {m}"); fallos.append(m)
    def ok(m): print(f"OK: {m}")

    with tempfile.TemporaryDirectory() as tmp:
        t = Path(tmp)
        # 1 recuento de atomos, ignorando lo que no es ATOM
        a = t / "basico.pdb"
        escribe(a, [(1, "N", "SER", 1, 1.0, 2.0, 3.0, 10.0),
                    (2, "CA", "SER", 1, 2.0, 2.0, 3.0, 12.0),
                    (3, "C", "SER", 1, 3.0, 2.0, 3.0, 14.0)],
                extras=["HETATM    9  O   HOH A 501       9.000   9.000   9.000  1.00 30.00           O"])
        rc, sal = corre(guion, a)
        if rc != 0:
            ko(f"sobre un fichero correcto el guion termina con error: {sal.strip().splitlines()[-1][:70] if sal.strip() else 'sin mensaje'}")
        else:
            if "ATOMOS:3" not in sal.replace(" ", ""):
                ko(f"no informa de 3 átomos de proteína; su salida fue: {sal.strip()[:90]}")
            if "4" in sal.split("ATOMOS:")[-1][:2] if "ATOMOS:" in sal else False:
                ko("parece contar la molécula de agua como átomo de la proteína")
        # 2 factor de temperatura medio y maximo
        b = t / "bfactores.pdb"
        escribe(b, [(1, "N", "ALA", 1, 0.0, 0.0, 0.0, 10.0),
                    (2, "CA", "ALA", 1, 1.0, 0.0, 0.0, 20.0),
                    (3, "C", "ALA", 1, 2.0, 0.0, 0.0, 60.0)])
        rc, sal = corre(guion, b)
        if "30.00" not in sal and "30.0" not in sal:
            ko("no informa del factor de temperatura medio, que en este caso es 30")
        if "60" not in sal:
            ko("no informa del factor de temperatura máximo, que en este caso es 60")
        if "AVISO" not in sal.upper():
            ko("no avisa de que hay átomos con factor de temperatura alto, por encima de 50")
        # 3 fichero con una linea corrupta
        c = t / "corrupto.pdb"
        contenido = a.read_text().splitlines()
        contenido.insert(2, "ATOM      2  CA")
        c.write_text("\n".join(contenido) + "\n", encoding="utf-8")
        rc, sal = corre(guion, c)
        if rc == 0 and "LINEA" not in sal.upper() and "MAL" not in sal.upper() and "INVALID" not in sal.upper():
            ko("una línea mal formada pasa desapercibida: el guion debe informar de ella")
        # 4 fichero sin atomos
        d = t / "vacio.pdb"
        d.write_text("HEADER    VACIO\nEND\n", encoding="utf-8")
        rc, sal = corre(guion, d)
        if rc == 0 and "0" not in sal:
            ko("con un fichero sin átomos el guion no dice nada; debe informar de que no hay ninguno")
        if not fallos:
            ok("cuenta solo los átomos de la proteína, informa de los factores de temperatura, avisa de los altos y detecta las líneas mal formadas")

    if fallos:
        print(f"PROCESADOR_INCOMPLETO: {len(fallos)} comprobaciones sin superar"); return 1
    print("PROCESADOR_OK: el procesador cumple su contrato"); return 0


if __name__ == "__main__":
    raise SystemExit(main())
