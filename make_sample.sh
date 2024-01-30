#!/bin/bash

INFILE=$1

K=31
BASENAME=$(basename $INFILE .fa)
DEPTH=10
NTHREADS=10
TESTDEPTH=1
NUM_SAMPLES=1
TEST_SEED=2
OUTDIR=nobackup/samples
LOGDIR=nobackup/logs
DBGDIR=nobackup/k$K
CLUSTERDIR=nobackup/k$K/clusters
TESTILLUMINADIR=nobackup/illumina
TESTCLRDIR=nobackup/clr
TESTHIFIDIR=nobackup/hifi
TESTONTDIR=nobackup/ont

SART_PARAMS="-ss HS25 -p -l 150 -f $DEPTH -m 200 -s 10"
ART_PARAMS="-ss HS25 -p -l 150 -f $TESTDEPTH -m 200 -s 10"
PBSIM_PARAMS="--strategy wgs --method errhmm --errhmm ERRHMM-SEQUEL.model --depth $TESTDEPTH --seed $TEST_SEED"
ONTSIM_PARAMS="--strategy wgs --method errhmm --errhmm ERRHMM-ONT.model --depth $TESTDEPTH --seed $TEST_SEED"

mkdir -p $OUTDIR
mkdir -p $LOGDIR
mkdir -p $DBGDIR
mkdir -p $CLUSTERDIR
mkdir -p $DBG2DIR
mkdir -p $TESTILLUMINADIR
mkdir -p $TESTCLRDIR
mkdir -p $TESTHIFIDIR
mkdir -p $TESTONTDIR

for j in $(seq 1 $NUM_SAMPLES); do
    SAMPLE_FILE_PREFIX="$BASENAME.reads.$DEPTH.$j"
    TEST_FILE_PREFIX="$BASENAME.reads.$TESTDEPTH.$j"

    # generate graph reads
    ./art_illumina -i $INFILE $SART_PARAMS -o $OUTDIR/$SAMPLE_FILE_PREFIX. --rndSeed $j
    reformat.sh in=$OUTDIR/$SAMPLE_FILE_PREFIX.1.fq in2=$OUTDIR/$SAMPLE_FILE_PREFIX.2.fq out=$OUTDIR/$SAMPLE_FILE_PREFIX.fa.gz fastawrap=-1 overwrite=true
    rm $OUTDIR/$SAMPLE_FILE_PREFIX.*aln $OUTDIR/$SAMPLE_FILE_PREFIX.*.fq

    # generate assembly graph
    ./assemble.sh $OUTDIR/$SAMPLE_FILE_PREFIX.fa.gz

    # generate path cover
    ./path_cover.sh $OUTDIR/$SAMPLE_FILE_PREFIX.fa.gz

    # generate test reads
    # illumina
    ./art_illumina -i $INFILE $ART_PARAMS -o $TESTILLUMINADIR/$TEST_FILE_PREFIX. --rndSeed $TEST_SEED
    reformat.sh in=$TESTILLUMINADIR/$TEST_FILE_PREFIX.1.fq in2=$TESTILLUMINADIR/$TEST_FILE_PREFIX.2.fq out=$TESTILLUMINADIR/$TEST_FILE_PREFIX.fa.gz fastawrap=-1 overwrite=true
    rm $TESTILLUMINADIR/$TEST_FILE_PREFIX.*aln $TESTILLUMINADIR/$TEST_FILE_PREFIX.*.fq

    # PB CLR
    ./pbsim $PBSIM_PARAMS --genome $INFILE --prefix $TESTCLRDIR/$TEST_FILE_PREFIX
    reformat.sh in=$TESTCLRDIR/${TEST_FILE_PREFIX}_0001.fastq out=$TESTCLRDIR/$TEST_FILE_PREFIX.fa.gz fastawrap=-1 overwrite=true
    rm $TESTCLRDIR/${TEST_FILE_PREFIX}_0001.fastq $TESTCLRDIR/${TEST_FILE_PREFIX}_0001.maf $TESTCLRDIR/${TEST_FILE_PREFIX}_0001.ref

    # PB HIFI
    ./pbsim $PBSIM_PARAMS --genome $INFILE --prefix $TESTHIFIDIR/$TEST_FILE_PREFIX --pass-num 10
    samtools view -b -h $TESTHIFIDIR/${TEST_FILE_PREFIX}_0001.sam > $TESTHIFIDIR/${TEST_FILE_PREFIX}_0001.bam
    rm $TESTHIFIDIR/${TEST_FILE_PREFIX}_0001.sam
    ccs --min-passes 10 $TESTHIFIDIR/${TEST_FILE_PREFIX}_0001.bam $TESTHIFIDIR/$TEST_FILE_PREFIX.fa.gz
    rm $TESTHIFIDIR/${TEST_FILE_PREFIX}_0001.bam $TESTHIFIDIR/${TEST_FILE_PREFIX}_0001.maf $TESTHIFIDIR/${TEST_FILE_PREFIX}_0001.ref $TESTHIFIDIR/${TEST_FILE_PREFIX}.ccs_report.txt $TESTHIFIDIR/${TEST_FILE_PREFIX}.zmw_metrics.json.gz

    # ONT
    ./pbsim $ONTSIM_PARAMS --genome $INFILE --prefix $TESTONTDIR/$TEST_FILE_PREFIX
    reformat.sh in=$TESTONTDIR/${TEST_FILE_PREFIX}_0001.fastq out=$TESTONTDIR/$TEST_FILE_PREFIX.fa.gz fastawrap=-1 overwrite=true
    rm $TESTONTDIR/${TEST_FILE_PREFIX}_0001.fastq $TESTONTDIR/${TEST_FILE_PREFIX}_0001.maf $TESTONTDIR/${TEST_FILE_PREFIX}_0001.ref
done
