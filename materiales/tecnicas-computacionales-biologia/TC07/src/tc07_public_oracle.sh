#!/usr/bin/env bash
# Oráculo de prueba independiente del candidato. Deriva resultados desde el
# FASTA efectivo; no contiene filas esperadas ni la solución de classify_pair.
set -euo pipefail

die() { printf 'ORACLE_ERROR: %s\n' "$1" >&2; exit "${2:-65}"; }
[[ $# -ge 2 ]] || die 'usage: tc07_public_oracle.sh {summary|windows} FASTA [ID WIDTH]' 64
mode=$1
fasta=$2
[[ -f "$fasta" && -r "$fasta" ]] || die 'FASTA is not readable' 66

case "$mode" in
  summary)
    [[ $# -eq 2 ]] || die 'summary expects FASTA' 64
    LC_ALL=C gawk '
      function fail(message, code) { print "ORACLE_ERROR: " message > "/dev/stderr"; exit code }
      function log2(x) { return log(x)/log(2) }
      function emit() {
        if (id=="") return
        if (sequence=="") fail("empty record",67)
        if (sequence!~/^[ACGT]+$/) fail("invalid alphabet",68)
        delete count
        n=length(sequence); entropy=0; total=0
        for (i=1;i<=n;i++) count[substr(sequence,i,1)]++
        for (i=1;i<=4;i++) { symbol=substr("ACGT",i,1); p=count[symbol]/n; total+=p; if (p>0) entropy-=p*log2(p) }
        printf "%s\t%d\t%d\t%d\t%d\t%d\t%.6f\t%.6f\n", id,n,count["A"],count["C"],count["G"],count["T"],total,entropy
      }
      BEGIN { print "id\tlength\tA\tC\tG\tT\tprobability_sum\tH0_bits" }
      /^>/ {
        emit(); header=substr($0,2); sub(/^[[:space:]]+/,"",header); split(header,part,/[[:space:]]+/)
        id=part[1]; if (id=="") fail("empty identifier",69); if (seen[id]++) fail("duplicate identifier",72)
        sequence=""; records++; next
      }
      {
        line=toupper($0); gsub(/[[:space:]]/,"",line)
        if (id=="" && line!="") fail("sequence before header",70)
        sequence=sequence line
      }
      END { if (records==0) fail("no records",71); emit() }
    ' "$fasta"
    ;;
  windows)
    [[ $# -eq 4 ]] || die 'windows expects FASTA ID WIDTH' 64
    wanted=$3
    width=$4
    [[ "$width" =~ ^[1-9][0-9]*$ ]] || die 'WIDTH must be positive' 65
    LC_ALL=C gawk -v wanted="$wanted" -v width="$width" '
      function fail(message, code) { print "ORACLE_ERROR: " message > "/dev/stderr"; exit code }
      function log2(x) { return log(x)/log(2) }
      function finish_record() {
        if (id!=wanted) return
        if (sequence=="") fail("empty record",67)
        if (sequence!~/^[ACGT]+$/) fail("invalid alphabet",68)
        selected=sequence; found++
      }
      /^>/ {
        finish_record(); header=substr($0,2); sub(/^[[:space:]]+/,"",header); split(header,part,/[[:space:]]+/)
        id=part[1]; sequence=""; next
      }
      {
        line=toupper($0); gsub(/[[:space:]]/,"",line); sequence=sequence line
      }
      END {
        finish_record()
        if (found!=1) fail("record must occur once",72)
        if (width>length(selected)) fail("WIDTH exceeds sequence",65)
        print "start\tend\twindow\tH0_bits"
        for (start=1;start<=length(selected)-width+1;start++) {
          window=substr(selected,start,width); delete count; entropy=0
          for (i=1;i<=width;i++) count[substr(window,i,1)]++
          for (i=1;i<=4;i++) { symbol=substr("ACGT",i,1); if (count[symbol]>0) { p=count[symbol]/width; entropy-=p*log2(p) } }
          printf "%d\t%d\t%s\t%.6f\n",start,start+width-1,window,entropy
        }
      }
    ' "$fasta"
    ;;
  *) die 'unknown mode' 64 ;;
esac
