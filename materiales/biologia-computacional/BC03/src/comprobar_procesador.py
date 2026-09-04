#!/usr/bin/env python3
"""Prueba el procesador de variantes del alumnado contra su contrato.

Uso: comprobar_procesador.py RUTA_DEL_GUION
Ejecuta el guion sobre ficheros que el enunciado no muestra, entre ellos uno
con una variante en el primer nucleótido del cromosoma, que es donde falla una
conversión de coordenadas hecha a la ligera.
"""
from __future__ import annotations

import subprocess
import sys
import tempfile
from pathlib import Path

TI = {("A", "G"), ("G", "A"), ("C", "T"), ("T", "C")}

CASOS = [
    # (nombre, variantes, ti, tv)
    ("lote_equilibrado", [("A", "G"), ("C", "T"), ("G", "A"), ("T", "C"), ("A", "C"), ("G", "T")], 4, 2),
    ("lote_sospechoso", [("A", "C"), ("G", "T"), ("C", "A"), ("T", "G"), ("A", "G")], 1, 4),
]


def escribe_vcf(ruta: Path, variantes, primera_en_uno: bool = False) -> None:
    lineas = ["##fileformat=VCFv4.2", "#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO"]
    pos = 1 if primera_en_uno else 100
    for i, (r, a) in enumerate(variantes, 1):
        lineas.append(f"chrT\t{pos}\tv{i:03d}\t{r}\t{a}\t50\tPASS\t.")
        pos += 137
    ruta.write_text("\n".join(lineas) + "\n", encoding="utf-8")


def corre(guion: Path, vcf: Path):
    r = subprocess.run(["python3", str(guion), str(vcf)], capture_output=True, text=True, timeout=60)
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
        for nombre, variantes, ti, tv in CASOS:
            vcf = t / f"{nombre}.vcf"
            escribe_vcf(vcf, variantes)
            rc, sal = corre(guion, vcf)
            if rc != 0:
                ko(f"sobre {nombre} el guion termina con error: {sal.strip().splitlines()[-1][:70] if sal.strip() else 'sin mensaje'}")
                continue
            if f"TI:{ti}" not in sal.replace(" ", "") and f"TI: {ti}" not in sal:
                ko(f"sobre {nombre} no informa de {ti} transiciones; su salida fue: {sal.strip()[:80]}")
            if f"TV:{tv}" not in sal.replace(" ", "") and f"TV: {tv}" not in sal:
                ko(f"sobre {nombre} no informa de {tv} transversiones")
        # el aviso de calidad
        vcf = t / "sospechoso.vcf"
        escribe_vcf(vcf, CASOS[1][1])
        rc, sal = corre(guion, vcf)
        if "AVISO" not in sal.upper():
            ko("con un cociente de 0,25 el guion no emite ningún aviso de calidad")
        vcf = t / "normal.vcf"
        escribe_vcf(vcf, CASOS[0][1])
        rc, sal = corre(guion, vcf)
        if "AVISO" in sal.upper():
            ko("con un cociente de 2,0, que es normal, el guion emite un aviso que no toca")
        # la variante en la posición 1
        vcf = t / "borde.vcf"
        escribe_vcf(vcf, [("A", "G"), ("C", "T")], primera_en_uno=True)
        rc, sal = corre(guion, vcf)
        if rc != 0:
            ko("una variante en la posición 1 del cromosoma rompe el guion: revise la conversión de coordenadas")
        elif "-1" in sal:
            ko("una variante en la posición 1 produce un índice negativo en la salida")
        if not fallos:
            ok("clasifica bien los dos lotes, avisa solo cuando el cociente se sale de lo esperado y trata la posición 1 sin romperse")

    if fallos:
        print(f"PROCESADOR_INCOMPLETO: {len(fallos)} comprobaciones sin superar"); return 1
    print("PROCESADOR_OK: el procesador cumple su contrato"); return 0


if __name__ == "__main__":
    raise SystemExit(main())
