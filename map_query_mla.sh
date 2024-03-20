#!/bin/bash

PARAMS="align -i fungi.dbg -a fungi.row_diff_brwt_coord.annodbg -a fungi.seq.column.annodbg --align-edit-distance -v --align-profile mla $1"

mkdir -p alignments

echo "With MLA chaining"
OUTPREFIX="alignments/$(basename $1).0.01.mla"
/usr/bin/time -v ./metagraph $PARAMS >$OUTPREFIX.tsv 2>$OUTPREFIX.log
./classify_mg.py $OUTPREFIX.tsv $1 >$OUTPREFIX.tsv.wgsunifrac.sweep.tsv 2>$OUTPREFIX.tsv.wgsunifrac.sweep.log

OUTPREFIX="alignments/$(basename $1).0.01.mlafixha"
/usr/bin/time -v ./metagraph $PARAMS --align-fixed-haplotype 10 >$OUTPREFIX.tsv 2>$OUTPREFIX.log
./classify_mg.py $OUTPREFIX.tsv $1 >$OUTPREFIX.tsv.wgsunifrac.sweep.tsv 2>$OUTPREFIX.tsv.wgsunifrac.sweep.log

OUTPREFIX="alignments/$(basename $1).0.01.mlanonlc"
/usr/bin/time -v ./metagraph $PARAMS --align-fixed-haplotype -10 >$OUTPREFIX.tsv 2>$OUTPREFIX.log
./classify_mg.py $OUTPREFIX.tsv $1 >$OUTPREFIX.tsv.wgsunifrac.sweep.tsv 2>$OUTPREFIX.tsv.wgsunifrac.sweep.log

