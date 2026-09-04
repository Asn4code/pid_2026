#!/usr/bin/env bash
# Crea el espacio de trabajo del anexo de BC-CH14: la biblioteca de compuestos
# con su manifiesto, el comprobador público y una plantilla vacía del módulo.
# Uso: practice_assets/create_workspace.sh [DESTINO]   (por defecto BC14_entrega)
set -euo pipefail
DEST="${1:-BC14_entrega}"
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CAP="$(cd "$AQUI/.." && pwd)"
if [ -e "$DEST" ]; then echo "ERROR: '$DEST' ya existe; elija otro nombre o retírelo antes." >&2; exit 1; fi
mkdir -p "$DEST/data" "$DEST/notas" "$DEST/resultados" "$DEST/verification"
cp -r -- "$CAP/data/." "$DEST/data/"
cp -- "$CAP/verification/practice_checks.py" "$CAP/verification/chapter_checks.py" "$DEST/verification/"
cp -- "$AQUI/comprobar_cribado.py" "$DEST/verification/comprobar_cribado.py"
cat > "$DEST/check_cribado.sh" <<'EOF'
#!/usr/bin/env bash
# Prueba mi_cribado.py contra su contrato. Ejecutelo cuantas veces quiera.
set -uo pipefail
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
python3 "$AQUI/verification/comprobar_cribado.py" "${1:-$AQUI/mi_cribado.py}"
EOF
chmod +x "$DEST/check_cribado.sh"
cat > "$DEST/mi_cribado.py" <<'EOF'
#!/usr/bin/env python3
"""Modulo de cribado de BC-CH14. Escriba aqui su implementacion.

Contrato que comprueba verification/comprobar_cribado.py:

  velocity_verlet_step(x0, v0, a0, a1, dt)
      devuelve la pareja (x1, v1) del paso completo. La velocidad usa el
      promedio de la aceleracion actual y la recalculada en la posicion nueva.
      Lanza ValueError si el paso de tiempo no es positivo.

  kd_ilustrativa_um(delta_g, temperature_k=298.15)
      constante de disociacion en micromolar a partir de una energia libre
      estandar de union en kcal/mol. Lanza ValueError con temperatura no
      positiva. Es ilustrativa: aplicada a una puntuacion de acoplamiento el
      resultado no es una afinidad predicha.

  tanimoto(a, b, c)
      coeficiente entre dos huellas: a bits activos en la primera, b en la
      segunda y c comunes. Dos huellas sin ningun bit activo se consideran
      identicas y dan 1.0. Rechaza recuentos negativos y c mayor que a o b.

  violaciones_ro5(mw, logp, hbd, hba)
      devuelve un diccionario con la clave 'violaciones', el recuento de
      criterios incumplidos de la regla de cinco, y la clave
      'riesgo_absorcion', que vale 'alto' con dos o mas violaciones y 'bajo'
      en caso contrario. Los criterios son 'no mayor que': el valor limite no
      cuenta como violacion. La funcion no decide si el compuesto sirve.
"""


def velocity_verlet_step(x0: float, v0: float, a0: float, a1: float, dt: float):
    raise NotImplementedError("escriba velocity_verlet_step")


def kd_ilustrativa_um(delta_g: float, temperature_k: float = 298.15) -> float:
    raise NotImplementedError("escriba kd_ilustrativa_um")


def tanimoto(a: int, b: int, c: int) -> float:
    raise NotImplementedError("escriba tanimoto")


def violaciones_ro5(mw: float, logp: float, hbd: int, hba: int) -> dict:
    raise NotImplementedError("escriba violaciones_ro5")
EOF
printf 'orden\tcompuesto\tscore\tviolaciones_ro5\ttanimoto\tkd_ilustrativa_um\tpapel\tjustificacion\n' > "$DEST/notas/ranking.tsv"
echo "Espacio de trabajo creado en '$DEST': mi_cribado.py (plantilla vacía), data/ con los diez compuestos y su manifiesto, verification/ con el comprobador público, notas/ranking.tsv (solo cabecera) y resultados/ (vacía)"
