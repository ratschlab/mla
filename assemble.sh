#!/bin/bash

METAGRAPH_DIR=~/apps/metagraph/metagraph/build_mla_ng
METAGRAPH=$METAGRAPH_DIR/metagraph
KMC=$METAGRAPH_DIR/KMC/kmc

mkdir -p assemblies

F=$1
PREFIX=assemblies/$(basename $F)

mkdir -p $PREFIX.tmp
/usr/bin/time -v $KMC -k31 -fm -ci1 -t1 $F $PREFIX $PREFIX.tmp/ >$PREFIX.kmc.log 2>&1
rmdir $PREFIX.tmp
NUM_UNIQUE=$(grep -F "No. of unique k-mers" $PREFIX.kmc.log | awk '{print $(NF)}')
NUM_KMERS=$(grep -F "Total no. of k-mers" $PREFIX.kmc.log | awk '{print $(NF)}')
COVERAGE=$(echo $NUM_UNIQUE $NUM_KMERS | awk '{print $2/$1}')

#fallback = 5 if kmer_coverage > 5 else 2 if kmer_coverage > 2 or kmer_count_unique > 1e6 else 1
if [[ $COVERAGE > 5 ]]; then
    FALLBACK=5
elif [[ $COVERAGE > 2 || $NUM_UNIQUE > 1000000 ]]; then
    FALLBACK=2
else
    FALLBACK=1
fi

echo $(basename $F) $NUM_KMERS $NUM_UNIQUE $COVERAGE $FALLBACK

/usr/bin/time -v $METAGRAPH build -k 31 -o $PREFIX $PREFIX.kmc_suf --mode canonical -v --count-kmers >$PREFIX.log 2>&1
/usr/bin/time -v $METAGRAPH clean -v $PREFIX.dbg --unitigs -o $PREFIX.clean --prune-unitigs 0 --prune-tips 62 --fallback $FALLBACK >$PREFIX.clean.log 2>&1
/usr/bin/time -v $METAGRAPH build -k 31 -o $PREFIX.clean $PREFIX.clean.fasta.gz -v >$PREFIX.build_clean.log 2>&1
