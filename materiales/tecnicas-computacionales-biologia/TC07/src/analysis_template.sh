#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
analyzer="$script_dir/lib/tc07_analyze.sh"

usage() {
  printf '%s\n' \
    "usage: $0 analyze INPUT.fasta NEW_OUTPUT_DIRECTORY" \
    "       $0 classify VALUE_1 VALUE_2 TOLERANCE" >&2
  exit 64
}

classify_pair() {
  local first=$1
  local second=$2
  local tolerance=$3

  # BEGIN-TODO-TC07
  # TODO-TC07: implementa la comparación numérica simétrica descrita en el PDF.
  # Debe imprimir solo SAME_H0 o DIFFERENT_H0 y rechazar entradas no numéricas.
  printf 'PENDING\n'
  return 78
  # END-TODO-TC07
}

record_controls() {
  local staging=$1 log=$2 observed
  check_label() {
    local expected=$1 first=$2 second=$3 tolerance=$4
    observed=$(classify_pair "$first" "$second" "$tolerance") || return 1
    [[ "$observed" == "$expected" ]]
  }
  check_label SAME_H0 1.0 1.0 0.000001 || return 1
  check_label SAME_H0 1.0000004 1.0 0.000001 || return 1
  check_label SAME_H0 1.000001 1.0 0.000001 || return 1
  check_label SAME_H0 0.999999 1.0 0.000001 || return 1
  check_label DIFFERENT_H0 1.000002 1.0 0.000001 || return 1
  check_label DIFFERENT_H0 0.999998 1.0 0.000001 || return 1
  if classify_pair text 1.0 0.1 >/dev/null 2>&1; then return 1; fi
  if classify_pair 1.0 1.0 -0.1 >/dev/null 2>&1; then return 1; fi
  if "$analyzer" summaries "$script_dir/data/tc07_invalid.fasta" >/dev/null 2>&1; then return 1; fi
  if "$analyzer" summaries "$script_dir/data/tc07_empty_record.fasta" >/dev/null 2>&1; then return 1; fi
  [[ $(head -n 1 "$staging/summary.tsv") == $'id\tlength\tA\tC\tG\tT\tprobability_sum\tH0_bits' ]] || return 1
  [[ $(head -n 1 "$staging/blocks_w4.tsv") == $'start\tend\twindow\tH0_bits' ]] || return 1
  [[ $(head -n 1 "$staging/blocks_w8.tsv") == $'start\tend\twindow\tH0_bits' ]] || return 1
  [[ $(head -n 1 "$staging/classification.tsv") == $'pair\tclassification\ttolerance' ]] || return 1
  printf '%s\tPASS\n' \
    CONTROL_CLASSIFY_EQUALITY \
    CONTROL_CLASSIFY_INTERIOR \
    CONTROL_CLASSIFY_BORDER_UPPER \
    CONTROL_CLASSIFY_BORDER_LOWER \
    CONTROL_CLASSIFY_OUTSIDE_UPPER \
    CONTROL_CLASSIFY_OUTSIDE_LOWER \
    CONTROL_CLASSIFY_NONNUMERIC \
    CONTROL_CLASSIFY_NEGATIVE_TOLERANCE \
    CONTROL_INVALID_FASTA \
    CONTROL_EMPTY_FASTA \
    CONTROL_SUMMARY_SCHEMA \
    CONTROL_WINDOWS_W4_SCHEMA \
    CONTROL_WINDOWS_W8_SCHEMA \
    CONTROL_CLASSIFICATION_SCHEMA \
    CONTROL_DESTINATION_NEW >> "$log"
}

analyze() {
  local input=$1
  local output_dir=$2
  [[ -f "$input" ]] || { printf 'ERROR: input is not a file: %s\n' "$input" >&2; return 66; }
  [[ ! -e "$output_dir" ]] || { printf 'ERROR: output exists: %s\n' "$output_dir" >&2; return 73; }
  local parent temporary blocks_h interleaved_h classification
  parent=$(dirname -- "$output_dir")
  [[ -d "$parent" ]] || { printf 'ERROR: output parent does not exist: %s\n' "$parent" >&2; return 74; }
  temporary=$(mktemp -d "$parent/.tc07-delivery.XXXXXX")
  trap 'rm -rf -- "$temporary"' RETURN

  "$analyzer" write-summaries "$input" "$temporary/summary.tsv" >/dev/null
  "$analyzer" write-windows "$input" blocks 4 "$temporary/blocks_w4.tsv" >/dev/null
  "$analyzer" write-windows "$input" blocks 8 "$temporary/blocks_w8.tsv" >/dev/null

  blocks_h=$(LC_ALL=C gawk -F '\t' '$1=="blocks"{print $8}' "$temporary/summary.tsv")
  interleaved_h=$(LC_ALL=C gawk -F '\t' '$1=="interleaved"{print $8}' "$temporary/summary.tsv")
  [[ -n "$blocks_h" && -n "$interleaved_h" ]] || {
    printf 'ERROR: required pair not found in input\n' >&2
    return 72
  }
  classification=$(classify_pair "$blocks_h" "$interleaved_h" 0.000001)
  [[ "$classification" == SAME_H0 || "$classification" == DIFFERENT_H0 ]] || {
    printf 'ERROR: invalid classification: %s\n' "$classification" >&2
    return 78
  }
  printf 'pair\tclassification\ttolerance\nblocks_interleaved\t%s\t0.000001\n' \
    "$classification" > "$temporary/classification.tsv"

  {
    bash "$script_dir/check_environment.sh"
    (cd "$script_dir" && sha256sum --check --strict manifest.sha256 >/dev/null)
    printf 'INPUT_SHA256\t%s\n' "$(sha256sum "$input" | LC_ALL=C gawk '{print $1}')"
  } > "$temporary/controls.log"
  record_controls "$temporary" "$temporary/controls.log" || {
    printf 'ERROR: internal control battery failed\n' >&2
    return 75
  }

  mv -- "$temporary" "$output_dir"
  trap - RETURN
  printf 'DELIVERY_WRITTEN\t%s\n' "$output_dir"
}

(( $# >= 1 )) || usage
mode=$1
shift
case "$mode" in
  analyze)
    (( $# == 2 )) || usage
    analyze "$1" "$2"
    ;;
  classify)
    (( $# == 3 )) || usage
    classify_pair "$1" "$2" "$3"
    ;;
  *) usage ;;
esac
