#!/bin/bash

PARAMS="align -i fungi.dbg -a fungi.row_diff_brwt_coord.annodbg -a fungi.seq.column.annodbg --align-edit-distance -v --align-profile SCA $1"

mkdir -p alignments

echo "With chaining"
OUTPREFIX="alignments/$(basename $1).0.01"
/usr/bin/time -v ./metagraph $PARAMS >$OUTPREFIX.tsv 2>$OUTPREFIX.log
./classify_mg.py $OUTPREFIX.tsv $1 >$OUTPREFIX.tsv.wgsunifrac.sweep.tsv 2>$OUTPREFIX.tsv.wgsunifrac.sweep.log

