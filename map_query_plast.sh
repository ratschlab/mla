#!/bin/bash

mkdir -p plast_aln

/usr/bin/time -v ./PLAST Search -i fungi.plast -q <(cat $1 | paste - - | cut -f2 | tr -c "ATGC\n" "A") -w 19 -d -1 -r > plast_aln/$(basename $1).plast.out 2>plast_aln/$(basename $1).plast.log

PARSED="plast_aln/$(basename $1).plast.out.parsed"
./parse_plast plast_aln/$(basename $1).plast.out >$PARSED
./classify_plast.py $PARSED $1 >$PARSED.wgsunifrac.sweep.tsv 2>$PARSED.wgsunifrac.sweep.log
