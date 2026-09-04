#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf '%s\n' \
    'usage:' \
    '  tc07_analyze.sh summaries FASTA' \
    '  tc07_analyze.sh windows FASTA RECORD_ID WIDTH' \
    '  tc07_analyze.sh pair FASTA RECORD_ID_1 RECORD_ID_2' \
    '  tc07_analyze.sh write-summaries FASTA OUTPUT.tsv' \
    '  tc07_analyze.sh write-windows FASTA RECORD_ID WIDTH OUTPUT.tsv' >&2
  exit 64
}

die() {
  local status=$1
  shift
  printf 'ERROR: %s\n' "$*" >&2
  exit "$status"
}

require_file() {
  local path=$1
  [[ -f "$path" ]] || die 66 "input is not a regular file: $path"
  [[ -r "$path" ]] || die 66 "input is not readable: $path"
}

# Produce one tab-separated id/sequence row per FASTA record. Headers never
# enter the sequence, wrapped lines are joined, and input order is preserved.
fasta_records() {
  local fasta=$1
  LC_ALL=C gawk '
    function fail(message, code) {
      print "ERROR: " message > "/dev/stderr"
      exit code
    }
    function emit_previous() {
      if (id == "") return
      if (sequence == "") fail("empty FASTA record: " id, 67)
      if (sequence !~ /^[ACGT]+$/) fail("invalid alphabet in FASTA record: " id, 68)
      print id "\t" sequence
    }
    /^>/ {
      emit_previous()
      header=substr($0, 2)
      sub(/^[[:space:]]+/, "", header)
      split(header, fields, /[[:space:]]+/)
      id=fields[1]
      if (id == "") fail("empty FASTA identifier", 69)
      sequence=""
      records++
      next
    }
    {
      line=toupper($0)
      gsub(/[[:space:]]/, "", line)
      if (id == "" && line != "") fail("sequence before first FASTA header", 70)
      sequence=sequence line
    }
    END {
      if (records == 0) fail("FASTA contains no records", 71)
      emit_previous()
    }
  ' "$fasta"
}

summaries() {
  local fasta=$1
  fasta_records "$fasta" | LC_ALL=C gawk -F '\t' '
    function log2(x) { return log(x)/log(2) }
    BEGIN { OFS="\t"; print "id", "length", "A", "C", "G", "T", "probability_sum", "H0_bits" }
    {
      id=$1; sequence=$2; n=length(sequence)
      delete count
      for (i=1; i<=n; i++) count[substr(sequence,i,1)]++
      h=0; total_p=0
      for (i=1; i<=4; i++) {
        symbol=substr("ACGT",i,1)
        p=count[symbol]/n
        total_p+=p
        if (p>0) h-=p*log2(p)
      }
      printf "%s\t%d\t%d\t%d\t%d\t%d\t%.6f\t%.6f\n", \
        id, n, count["A"], count["C"], count["G"], count["T"], total_p, h
    }
  '
}

sequence_for_id() {
  local fasta=$1
  local wanted=$2
  local selected
  selected=$(fasta_records "$fasta" | LC_ALL=C gawk -F '\t' -v wanted="$wanted" '
    $1==wanted { print $2; found++ }
    END {
      if (found==0) exit 3
      if (found>1) exit 4
    }
  ') || {
    local status=$?
    if (( status == 3 )); then die 72 "record not found: $wanted"; fi
    if (( status == 4 )); then die 72 "record identifier is duplicated: $wanted"; fi
    exit "$status"
  }
  printf '%s\n' "$selected"
}

windows() {
  local fasta=$1
  local wanted=$2
  local width=$3
  [[ "$width" =~ ^[1-9][0-9]*$ ]] || die 65 "WIDTH must be a positive integer"
  local sequence
  sequence=$(sequence_for_id "$fasta" "$wanted")
  (( width <= ${#sequence} )) || die 65 "WIDTH exceeds sequence length"
  LC_ALL=C gawk -v sequence="$sequence" -v width="$width" '
    function log2(x) { return log(x)/log(2) }
    BEGIN {
      OFS="\t"; print "start", "end", "window", "H0_bits"
      for (start=1; start<=length(sequence)-width+1; start++) {
        window=substr(sequence,start,width)
        delete count
        for (j=1; j<=width; j++) count[substr(window,j,1)]++
        h=0
        for (j=1; j<=4; j++) {
          symbol=substr("ACGT",j,1)
          if (count[symbol]>0) {
            p=count[symbol]/width
            h-=p*log2(p)
          }
        }
        printf "%d\t%d\t%s\t%.6f\n", start, start+width-1, window, h
      }
    }
  '
}

pair() {
  local fasta=$1
  local first=$2
  local second=$3
  summaries "$fasta" | LC_ALL=C gawk -F '\t' -v first="$first" -v second="$second" '
    BEGIN { OFS="\t"; print "id", "length", "A", "C", "G", "T", "H0_bits" }
    NR>1 && ($1==first || $1==second) {
      print $1, $2, $3, $4, $5, $6, $8
      found[$1]++
    }
    END {
      if (found[first]!=1 || found[second]!=1) exit 5
    }
  ' || die 72 "pair requires two distinct, existing identifiers"
}

write_summaries() {
  local fasta=$1
  local output=$2
  [[ ! -e "$output" ]] || die 73 "refusing to overwrite existing output: $output"
  local output_dir
  output_dir=$(dirname -- "$output")
  [[ -d "$output_dir" ]] || die 74 "output directory does not exist: $output_dir"
  local temporary
  temporary=$(mktemp "$output_dir/.tc07-summary.XXXXXX") || die 74 "cannot create temporary output"
  trap 'rm -f -- "$temporary"' EXIT
  summaries "$fasta" > "$temporary"
  mv -- "$temporary" "$output"
  trap - EXIT
  printf 'WROTE\t%s\n' "$output"
}

write_windows() {
  local fasta=$1
  local wanted=$2
  local width=$3
  local output=$4
  [[ ! -e "$output" ]] || die 73 "refusing to overwrite existing output: $output"
  local output_dir
  output_dir=$(dirname -- "$output")
  [[ -d "$output_dir" ]] || die 74 "output directory does not exist: $output_dir"
  local temporary
  temporary=$(mktemp "$output_dir/.tc07-windows.XXXXXX") || die 74 "cannot create temporary output"
  trap 'rm -f -- "$temporary"' EXIT
  windows "$fasta" "$wanted" "$width" > "$temporary"
  mv -- "$temporary" "$output"
  trap - EXIT
  printf 'WROTE\t%s\n' "$output"
}

(( $# >= 2 )) || usage
command=$1
shift
case "$command" in
  summaries)
    (( $# == 1 )) || usage
    require_file "$1"
    summaries "$1"
    ;;
  windows)
    (( $# == 3 )) || usage
    require_file "$1"
    windows "$1" "$2" "$3"
    ;;
  pair)
    (( $# == 3 )) || usage
    require_file "$1"
    [[ "$2" != "$3" ]] || die 72 "pair identifiers must differ"
    pair "$1" "$2" "$3"
    ;;
  write-summaries)
    (( $# == 2 )) || usage
    require_file "$1"
    write_summaries "$1" "$2"
    ;;
  write-windows)
    (( $# == 4 )) || usage
    require_file "$1"
    write_windows "$1" "$2" "$3" "$4"
    ;;
  *) usage ;;
esac
