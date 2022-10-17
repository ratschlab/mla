#!/bin/bash

K=31

SAMPLE_DIR=test_samples
TEMP_DIR=scratch
NUM_SAMPLES=1
mkdir -p $SAMPLE_DIR
mkdir -p $TEMP_DIR

TEST_DIR=test_reads
mkdir -p $TEST_DIR

TEST_NAMES=test_names.txt

rm -r $TEST_DIR/*
sed 's/samples\///g' $TEST_NAMES | cut -d"." -f-2 | while read BASE; do
    REF=refs/$BASE.fa
    PREFIX=$TEST_DIR/$BASE.test_reads
    art_illumina -ss HS25 -i $REF -p -l 150 -f 1 -m 200 -s 10 -o $PREFIX. --rndSeed $(( NUM_SAMPLES + 1 )) -ef
    rm $PREFIX.*.aln
    reformat.sh in=$PREFIX.1.fq in2=$PREFIX.2.fq out=$PREFIX.fa.gz fastawrap=-1 overwrite=true
    rm $PREFIX.*.fq
    samtools fasta $PREFIX._errFree.sam | gzip > $PREFIX.errFree.fa.gz
    rm $PREFIX.*.sam
done > $TEST_DIR/test_reads.out 2> $TEST_DIR/test_reads.log
rm $TEST_DIR.shuf.*
paste <(zcat $TEST_DIR/*.test_reads.fa.gz | paste - - - -) <(zcat $TEST_DIR/*.errFree.fa.gz | paste - - - -) | shuf --random-source=seed | awk -F"\t" '{
    if ($1 != $5) {
        print "FAIL";
        exit 1
    }
    print $1"\n"$2"\n"$3"\n"$4 >> "'$TEST_DIR.shuf.fa'";
    print $5"\n"$6"\n"$7"\n"$8 >> "'$TEST_DIR.shuf.errFree.fa'";
}'


sed 's/samples\///g' $TEST_NAMES | cut -d"." -f-2 | while read BASE; do
    REF=refs/$BASE.fa
    PREFIX=$TEST_DIR/$BASE.test_reads
    ./pbsim --prefix $PREFIX --depth 1 --data-type CLR --seed $(( NUM_SAMPLES + 1 )) --model_qc model_qc_clr $REF
    reformat.sh in=${PREFIX}_0001.fastq out=$PREFIX.pacbio.fa.gz fastawrap=-1 overwrite=true
    rm ${PREFIX}_0001.ref ${PREFIX}_0001.fastq
done > $TEST_DIR/test_reads.pacbio.out 2> $TEST_DIR/test_reads.pacbio.log
ls $TEST_DIR/*.test_reads.pacbio.fa.gz | while read F; do
    zcat $F | paste - - | awk '{print ">gi||rs|'$(basename $F | cut -d"." -f-2)'|,-"NR"/1\t"$2}';
done | shuf --random-source=seed | tr "\t" "\n" > $TEST_DIR.pacbio.shuf.fa

sed 's/samples\///g' $TEST_NAMES | cut -d"." -f-2 | while read BASE; do
    REF=refs/$BASE.fa
    PREFIX=$TEST_DIR/$BASE.test_reads
    ./pbsim --prefix $PREFIX --depth 1 --data-type CCS --seed $(( NUM_SAMPLES + 1 )) --model_qc model_qc_ccs $REF
    reformat.sh in=${PREFIX}_0001.fastq out=$PREFIX.hifi.fa.gz fastawrap=-1 overwrite=true ignorebadquality=true
    rm ${PREFIX}_0001.ref ${PREFIX}_0001.fastq
done > $TEST_DIR/test_reads.hifi.out 2> $TEST_DIR/test_reads.hifi.log
ls $TEST_DIR/*.test_reads.hifi.fa.gz | while read F; do
    zcat $F | paste - - | awk '{print ">gi||rs|'$(basename $F | cut -d"." -f-2)'|,-"NR"/1\t"$2}';
done | shuf --random-source=seed | tr "\t" "\n" > $TEST_DIR.hifi.shuf.fa
