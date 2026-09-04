#!/usr/bin/env bash
set -euo pipefail

if (( $# != 1 )); then
  printf 'usage: %s CANDIDATE_SCRIPT\n' "$0" >&2
  exit 64
fi

fail() { printf 'FAIL: %s\n' "$1" >&2; exit 1; }

candidate=$1
[[ -f "$candidate" ]] || fail candidate_not_found
if grep -Eq 'TODO-TC07|PENDING' "$candidate"; then fail unfinished_marker; fi
bash -n "$candidate"

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
oracle="$script_dir/lib/tc07_public_oracle.sh"
runtime_generator="$script_dir/lib/tc07_runtime_cases.sh"
[[ -x "$oracle" ]] || fail public_oracle_missing
[[ -x "$runtime_generator" ]] || fail runtime_generator_missing
(cd "$script_dir" && sha256sum --check --strict manifest.sha256 >/dev/null) || fail immutable_payload_changed

expect_classification() {
  local expected=$1 first=$2 second=$3 tolerance=$4 observed
  observed=$(bash "$candidate" classify "$first" "$second" "$tolerance") || fail "classify_command_${first}_${second}_${tolerance}"
  [[ "$observed" == "$expected" ]] || {
    printf 'FAIL: classification expected=%s observed=%s\n' "$expected" "$observed" >&2
    exit 1
  }
}

expect_rejected_classification() {
  if bash "$candidate" classify "$1" "$2" "$3" >/dev/null 2>&1; then
    fail "classification_input_accepted_${1}_${2}_${3}"
  fi
}

# Etiquetas y relaciones metamórficas ajenas al par FASTA congelado.
expect_classification SAME_H0 1.250000 1.250000 0.000001
expect_classification SAME_H0 1.0000004 1.0000000 0.000001
expect_classification SAME_H0 1.0000000 1.0000004 0.000001
expect_classification SAME_H0 1.0000010 1.0000000 0.000001
expect_classification SAME_H0 1.0000000 1.0000010 0.000001
expect_classification SAME_H0 0.9999990 1.0000000 0.000001
expect_classification SAME_H0 1.0000000 0.9999990 0.000001
expect_classification DIFFERENT_H0 1.0000020 1.0000000 0.000001
expect_classification DIFFERENT_H0 1.0000000 1.0000020 0.000001
expect_classification DIFFERENT_H0 0.9999980 1.0000000 0.000001
expect_classification DIFFERENT_H0 1.0000000 0.9999980 0.000001
expect_classification SAME_H0 2.0 2.0 0
expect_classification DIFFERENT_H0 2.1 2.0 0
expect_rejected_classification not_numeric 1.0 0.1
expect_rejected_classification 1.0 not_numeric 0.1
expect_rejected_classification 1.0 1.0 not_numeric
expect_rejected_classification 1.0 1.0 -0.1

temporary=$(mktemp -d)
trap 'rm -rf -- "$temporary"' EXIT

write_altered_fasta() {
  local output=$1 staging
  staging="$output.new"
  [[ ! -e "$output" && ! -e "$staging" ]] || fail altered_fasta_destination_exists
  printf '%s\n' \
    '>constant public-altered' \
    'CCCCCCCCCCCCCCCC' \
    '>uniform public-altered' \
    'AAAACCCCGGGGTTTTAAAA' \
    '>blocks public-altered' \
    'AAAAAAAACCCCGGGGTTTT' \
    '>interleaved public-altered' \
    'ACGTACGTACGTACGTACGT' \
    '>mixed public-altered' \
    'TTTTCCCCAAAAGGGGTTTT' > "$staging"
  mv -- "$staging" "$output"
}

validate_delivery() {
  local input=$1 output=$2 label=$3 expected
  expected="$temporary/expected-$label"
  mkdir "$expected"
  bash "$candidate" analyze "$input" "$output" >/dev/null
  for file in summary.tsv blocks_w4.tsv blocks_w8.tsv classification.tsv controls.log; do
    [[ -s "$output/$file" ]] || fail "${label}_missing_${file}"
  done
  [[ $(find "$output" -mindepth 1 -maxdepth 1 -type f | LC_ALL=C gawk 'END{print NR}') -eq 5 ]] || fail "${label}_unexpected_products"

  bash "$oracle" summary "$input" > "$expected/summary.tsv"
  bash "$oracle" windows "$input" blocks 4 > "$expected/blocks_w4.tsv"
  bash "$oracle" windows "$input" blocks 8 > "$expected/blocks_w8.tsv"
  cmp -s "$expected/summary.tsv" "$output/summary.tsv" || fail "${label}_summary_not_derived_from_input"
  cmp -s "$expected/blocks_w4.tsv" "$output/blocks_w4.tsv" || fail "${label}_w4_not_derived_from_input"
  cmp -s "$expected/blocks_w8.tsv" "$output/blocks_w8.tsv" || fail "${label}_w8_not_derived_from_input"

  classification_fields=$(LC_ALL=C gawk -F '\t' 'NR==2 { print $1, $2, $3 } END { if (NR!=2) exit 1 }' "$output/classification.tsv") || fail "${label}_classification_rows"
  read -r pair_name delivered_label delivered_tolerance <<< "$classification_fields"
  [[ "$pair_name" == blocks_interleaved ]] || fail "${label}_classification_pair"
  [[ "$delivered_label" == SAME_H0 || "$delivered_label" == DIFFERENT_H0 ]] || fail "${label}_classification_label"
  [[ "$delivered_tolerance" =~ ^(0|[0-9]+([.][0-9]*)?|[.][0-9]+)([eE][-+]?[0-9]+)?$ ]] || fail "${label}_classification_tolerance"
  blocks_h=$(LC_ALL=C gawk -F '\t' '$1=="blocks" { print $8 }' "$expected/summary.tsv")
  interleaved_h=$(LC_ALL=C gawk -F '\t' '$1=="interleaved" { print $8 }' "$expected/summary.tsv")
  expected_label=$(bash "$candidate" classify "$blocks_h" "$interleaved_h" "$delivered_tolerance") || fail "${label}_classification_recompute"
  [[ "$expected_label" == "$delivered_label" ]] || fail "${label}_classification_not_derived_from_input"

  input_hash=$(sha256sum "$input" | LC_ALL=C gawk '{print $1}')
  grep -q '^ENVIRONMENT_OK' "$output/controls.log" || fail "${label}_controls_environment"
  grep -qx $'INPUT_SHA256\t'"$input_hash" "$output/controls.log" || fail "${label}_controls_input_hash"
  for control in \
    CLASSIFY_EQUALITY CLASSIFY_INTERIOR CLASSIFY_BORDER_UPPER CLASSIFY_BORDER_LOWER \
    CLASSIFY_OUTSIDE_UPPER CLASSIFY_OUTSIDE_LOWER CLASSIFY_NONNUMERIC \
    CLASSIFY_NEGATIVE_TOLERANCE INVALID_FASTA EMPTY_FASTA SUMMARY_SCHEMA \
    WINDOWS_W4_SCHEMA WINDOWS_W8_SCHEMA CLASSIFICATION_SCHEMA DESTINATION_NEW; do
    grep -qx $'CONTROL_'"$control"$'\tPASS' "$output/controls.log" || fail "${label}_controls_${control}"
  done
}

# Un fallo temprano no puede publicar un directorio parcial.
for negative in tc07_invalid.fasta tc07_empty_record.fasta; do
  rejected="$temporary/rejected-${negative%.fasta}"
  if bash "$candidate" analyze "$script_dir/data/$negative" "$rejected" >/dev/null 2>&1; then fail "negative_fasta_accepted_${negative}"; fi
  [[ ! -e "$rejected" ]] || fail "partial_output_${negative}"
done

canonical_data="$script_dir/data/tc07_sequences.fasta"
altered_data="$temporary/public_altered.fasta"
write_altered_fasta "$altered_data"
canonical_output="$temporary/canonical-delivery"
altered_output="$temporary/altered-delivery"
validate_delivery "$canonical_data" "$canonical_output" canonical
validate_delivery "$altered_data" "$altered_output" altered

[[ $(sha256sum "$canonical_data" | LC_ALL=C gawk '{print $1}') != $(sha256sum "$altered_data" | LC_ALL=C gawk '{print $1}') ]] || fail altered_input_hash_unchanged
cmp -s "$canonical_output/summary.tsv" "$altered_output/summary.tsv" && fail altered_summary_unchanged
cmp -s "$canonical_output/blocks_w4.tsv" "$altered_output/blocks_w4.tsv" && fail altered_w4_unchanged
cmp -s "$canonical_output/blocks_w8.tsv" "$altered_output/blocks_w8.tsv" && fail altered_w8_unchanged
cmp -s "$canonical_output/classification.tsv" "$altered_output/classification.tsv" && fail altered_classification_unchanged

# Desafios no enumerables por hash antes de ejecutar: la semilla se elige en
# esta invocacion y puede fijarse solo para reproducir un fallo observado.
runtime_seed=${TC07_PUBLIC_SEED:-$(( ((RANDOM << 15) ^ RANDOM ^ BASHPID) & 2147483647 ))}
(( runtime_seed > 0 )) || runtime_seed=1
runtime_cases="$temporary/runtime-public"
bash "$runtime_generator" "$runtime_seed" "$runtime_cases" >/dev/null
printf 'RUNTIME_CHALLENGE\tscope=public\tseed=%s\tgenerator_sha256=%s\n' \
  "$runtime_seed" "$(sha256sum "$runtime_generator" | LC_ALL=C gawk '{print $1}')" >&2
for runtime_name in runtime_same runtime_different; do
  runtime_input="$runtime_cases/${runtime_name}.fasta"
  runtime_output="$temporary/${runtime_name}-delivery"
  printf 'RUNTIME_INPUT\tscope=public\tseed=%s\tcase=%s\tsha256=%s\n' \
    "$runtime_seed" "$runtime_name" "$(sha256sum "$runtime_input" | LC_ALL=C gawk '{print $1}')" >&2
  validate_delivery "$runtime_input" "$runtime_output" "$runtime_name"
done
runtime_same_label=$(LC_ALL=C gawk -F '\t' 'NR==2{print $2}' "$temporary/runtime_same-delivery/classification.tsv")
runtime_different_label=$(LC_ALL=C gawk -F '\t' 'NR==2{print $2}' "$temporary/runtime_different-delivery/classification.tsv")
[[ "$runtime_same_label" == SAME_H0 ]] || fail runtime_same_relation
[[ "$runtime_different_label" == DIFFERENT_H0 ]] || fail runtime_different_relation
cmp -s "$temporary/runtime_same-delivery/summary.tsv" "$temporary/runtime_different-delivery/summary.tsv" && fail runtime_summaries_trivial
cmp -s "$temporary/runtime_same-delivery/blocks_w4.tsv" "$temporary/runtime_different-delivery/blocks_w4.tsv" && fail runtime_w4_trivial
cmp -s "$temporary/runtime_same-delivery/blocks_w8.tsv" "$temporary/runtime_different-delivery/blocks_w8.tsv" && fail runtime_w8_trivial

before=$(find "$canonical_output" -type f -print0 | sort -z | xargs -0 sha256sum | sha256sum | LC_ALL=C gawk '{print $1}')
if bash "$candidate" analyze "$canonical_data" "$canonical_output" >/dev/null 2>&1; then fail overwrite_accepted; fi
after=$(find "$canonical_output" -type f -print0 | sort -z | xargs -0 sha256sum | sha256sum | LC_ALL=C gawk '{print $1}')
[[ "$before" == "$after" ]] || fail overwrite_changed_delivery

printf 'PUBLIC_SUBMISSION_CHECK_OK labels=pass oracle=pass altered_input=pass runtime_cases=2 profiles=pass classification=pass controls=pass atomic=pass\n'
