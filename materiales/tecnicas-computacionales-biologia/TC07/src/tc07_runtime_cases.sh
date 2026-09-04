#!/usr/bin/env bash
# Genera dos desafios positivos reproducibles desde una semilla elegida en
# tiempo de ejecucion. No calcula resultados ni comparte codigo con el oraculo.
set -euo pipefail

if (( $# != 2 )); then
  printf 'usage: %s SEED NEW_OUTPUT_DIRECTORY\n' "$0" >&2
  exit 64
fi
seed=$1
output=$2
[[ "$seed" =~ ^[1-9][0-9]*$ && "$seed" -le 2147483647 ]] || {
  printf 'ERROR: seed must be an integer in 1..2147483647\n' >&2
  exit 65
}
[[ ! -e "$output" ]] || { printf 'ERROR: output exists: %s\n' "$output" >&2; exit 73; }
parent=$(dirname -- "$output")
[[ -d "$parent" ]] || { printf 'ERROR: parent missing: %s\n' "$parent" >&2; exit 74; }
temporary=$(mktemp -d "$parent/.tc07-runtime.XXXXXX")
trap 'rm -rf -- "$temporary"' EXIT

LC_ALL=C gawk -v seed="$seed" -v output="$temporary" '
  function symbol(idx) { return substr("ACGT",idx+1,1) }
  function random_sequence(n, sequence, i) {
    sequence=""
    for (i=1;i<=n;i++) sequence=sequence symbol(int(rand()*4))
    return sequence
  }
  function repeated(base,n,sequence,i) {
    sequence=""; for (i=1;i<=n;i++) sequence=sequence base
    return sequence
  }
  function cycle(n,offset,sequence,i) {
    sequence=""; for (i=1;i<=n;i++) sequence=sequence symbol((offset+i-1)%4)
    return sequence
  }
  function emit_record(file,id,sequence,width,position) {
    print ">" id " runtime-seed=" seed > file
    for (position=1;position<=length(sequence);position+=width)
      print substr(sequence,position,width) > file
  }
  function shuffle(size, i,j,tmp) {
    for (i=size;i>1;i--) { j=1+int(rand()*i); tmp=order[i]; order[i]=order[j]; order[j]=tmp }
  }
  function write_case(file,size, i,key) {
    for (i=1;i<=size;i++) order[i]=i
    shuffle(size)
    for (i=1;i<=size;i++) {
      key=order[i]
      emit_record(file,identifier[key],sequence[key],3+int(rand()*6))
    }
    close(file)
    delete order; delete identifier; delete sequence
  }
  BEGIN {
    srand(seed)

    # Caso SAME: dos secuencias con igual composicion pero distinto orden.
    length_pair=8+int(rand()*17)
    pair=random_sequence(length_pair)
    identifier[1]="blocks"; sequence[1]=pair
    identifier[2]="interleaved"; sequence[2]=substr(pair,2) substr(pair,1,1)
    identifier[3]="aux_" seed "_" int(rand()*1000000); sequence[3]=random_sequence(9+int(rand()*18))
    identifier[4]="probe_" seed "_" int(rand()*1000000); sequence[4]=random_sequence(8+int(rand()*15))
    write_case(output "/runtime_same.fasta",4)

    # Caso DIFFERENT: entropia cero frente a una composicion de cuatro bases.
    length_pair=8+int(rand()*17); offset=int(rand()*4)
    identifier[1]="blocks"; sequence[1]=repeated(symbol(int(rand()*4)),length_pair)
    identifier[2]="interleaved"; sequence[2]=cycle(length_pair,offset)
    identifier[3]="aux_" seed "_" int(rand()*1000000); sequence[3]=random_sequence(10+int(rand()*17))
    identifier[4]="probe_" seed "_" int(rand()*1000000); sequence[4]=random_sequence(8+int(rand()*19))
    identifier[5]="check_" seed "_" int(rand()*1000000); sequence[5]=random_sequence(11+int(rand()*14))
    write_case(output "/runtime_different.fasta",5)
  }
' </dev/null

mv -- "$temporary" "$output"
trap - EXIT
printf 'RUNTIME_CASES_READY\tseed=%s\tdirectory=%s\n' "$seed" "$output"
