#!/bin/bash

K=31
INFILE=$1
BASENAME=$(basename $INFILE .fa)
DEPTH=1
NUM_SAMPLES=1
OUTDIR=samples
LOGDIR=logs
mkdir -p $OUTDIR
mkdir -p $LOGDIR

for j in $(seq 1 $NUM_SAMPLES); do
    SAMPLE_PREFIX="$OUTDIR/$BASENAME.reads.$DEPTH.$j"
    art_illumina -ss HS25 -i $INFILE -p -l 150 -f $DEPTH -m 200 -s 10 -o $SAMPLE_PREFIX. --rndSeed $j
    reformat.sh in=$SAMPLE_PREFIX.1.fq in2=$SAMPLE_PREFIX.2.fq out=$SAMPLE_PREFIX.fa.gz fastawrap=-1 overwrite=true
    rm $SAMPLE_PREFIX.*aln $SAMPLE_PREFIX.*.fq
    ./metagraph build -k $K -o $SAMPLE_PREFIX $SAMPLE_PREFIX.fa.gz --count-kmers --mode canonical
    ./metagraph clean --min-count 1 --prune-unitigs 0 --fallback 2 --prune-tips $(( K * 2 )) --to-fasta --primary-kmers -o $SAMPLE_PREFIX.clean $SAMPLE_PREFIX.dbg
    rm $SAMPLE_PREFIX.dbg* $SAMPLE_PREFIX.fa.gz
done >$LOGDIR/$BASENAME.$DEPTH.out 2>$LOGDIR/$BASENAME.$DEPTH.log
