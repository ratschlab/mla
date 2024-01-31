#!/bin/bash

CHAIN_XDROP=27

PARAMS="align --align-alternative-alignments 5 --align-chains-per-char 0.01 --align-ignore-discarded-seeds -i fungi.dbg --align-min-exact-match 0.0 --align-rel-score-cutoff 0.0 --align-edit-distance --align-gap-open-penalty 1 --align-gap-extension-penalty 1 -v $1 --batch-size 10000"

mkdir -p alignments

echo "With MLA chaining"
/usr/bin/time -v ./metagraph $PARAMS --align-xdrop $CHAIN_XDROP -a fungi.row_diff_brwt_coord.annodbg -a fungi.seq.column.annodbg --path-cover --align-post-chain >alignments/$(basename $1).$2.mla.tsv 2>alignments/$(basename $1).$2.mla.log
/usr/bin/time -v ./metagraph $PARAMS --align-xdrop $CHAIN_XDROP -a fungi.row_diff_brwt_coord.annodbg -a fungi.seq.column.annodbg --path-cover --align-post-chain --align-fixed-haplotype 10 >alignments/$(basename $1).$2.mlafixhap.tsv 2>alignments/$(basename $1).$2.mlafixhap.log
/usr/bin/time -v ./metagraph $PARAMS --align-xdrop $CHAIN_XDROP -a fungi.row_diff_brwt_coord.annodbg -a fungi.seq.column.annodbg --path-cover --align-post-chain --align-fixed-haplotype -10 >alignments/$(basename $1).$2.mlanonlc.tsv 2>alignments/$(basename $1).$2.mlanonlc.log

