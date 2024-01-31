#!/bin/bash

NREADS=100
PLATFORM=$1

mkdir -p query_reads

cat accession_list | while read F; do
    zcat nobackup/$PLATFORM/$F.*.fa.gz | paste - - | awk '{print ">'$F'-'$PLATFORM'-"NR"\t"$(NF)}'
done | shuf --random-source=seed2 | head -n $NREADS | tr "\t" "\n" > query_reads/$PLATFORM.query.fa
