#!/usr/bin/env bash
# Monta la raíz estudiantil de TC-CH07: el andamiaje de análisis con su parte
# pendiente marcada, la biblioteca de apoyo, los datos y el manifiesto.
# Uso: practice_assets/create_workspace.sh [DESTINO]   (por defecto TC07-student)
set -euo pipefail
DEST="${1:-TC07-student}"
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CAP="$(cd "$AQUI/.." && pwd)"
if [ -e "$DEST" ]; then echo "ERROR: '$DEST' ya existe; elija otro nombre o retírelo antes." >&2; exit 1; fi
mkdir -p "$DEST/lib" "$DEST/data" "$DEST/notas" "$DEST/resultados"
cp -- "$AQUI/analysis_template.sh" "$DEST/analysis_tc07.sh"
cp -- "$AQUI/check_environment.sh" "$DEST/check_environment.sh"
cp -- "$AQUI/check_submission_public.sh" "$DEST/check_submission.sh"
cp -- "$AQUI/bash_recovery.sh" "$DEST/lib/bash_recovery.sh"
cp -- "$AQUI/tc07_analyze.sh" "$DEST/lib/tc07_analyze.sh"
cp -- "$AQUI/tc07_public_oracle.sh" "$DEST/lib/tc07_public_oracle.sh"
cp -- "$AQUI/tc07_runtime_cases.sh" "$DEST/lib/tc07_runtime_cases.sh"
cp -- "$CAP/data/tc07_sequences.fasta" "$CAP/data/tc07_empty_record.fasta" "$CAP/data/tc07_invalid.fasta" "$DEST/data/"
chmod +x "$DEST"/*.sh "$DEST/lib/"*.sh
printf 'registro\tprediccion\tresultado\tcoincide\tjustificacion\n' > "$DEST/notas/respuestas.tsv"
( cd "$DEST" && sha256sum lib/*.sh data/*.fasta check_environment.sh > manifest.sha256 )
echo "Raíz estudiantil creada en '$DEST': analysis_tc07.sh con su parte pendiente marcada, lib/ con la biblioteca, data/ con los tres FASTA, notas/respuestas.tsv (solo cabecera) y manifest.sha256"
