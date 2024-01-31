#!/bin/bash

mkdir -p plast_aln

/usr/bin/time -v ./PLAST Search -i fungi -q <(cat $1 | paste - - | cut -f2 | tr -c "ATGC\n" "A") -w 19 -d -1 -r > plast_aln/$(basename $1).plast.out 2>plast_aln/$(basename $1).plast.log
./parse_plast plast_aln/$(basename $1).plast.out > plast_aln/$(basename $1).plast.out.parsed
