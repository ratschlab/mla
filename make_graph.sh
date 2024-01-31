#!/bin/bash

GRAPH=fungi
NTHREADS=10

# build metagraph index from walk covers
ls nobackup/assemblies/*.path_cover.fasta.gz | ./metagraph build -k 31 --fwd-and-reverse -o $GRAPH -p $NTHREADS

mkdir -p nobackup/columns
mkdir -p tmp
ls nobackup/assemblies/*.path_cover.fasta.gz | ./metagraph annotate -i $GRAPH.dbg -o nobackup/columns --anno-filename --separately --coordinates --anno-seq-ends -p $NTHREADS
for i in 0 1 2; do
    ls nobackup/columns/*.annodbg | ./metagraph transform_anno -p $NTHREADS --anno-type row_diff --coordinates -o out --row-diff-stage $i -i $GRAPH.dbg --disk-swap tmp
done
ls nobackup/columns/*.annodbg | ./metagraph transform_anno -p $NTHREADS --anno-type column --coordinates -o fungi
ls *.column.annodbg | ./metagraph transform_anno -p $NTHREADS -i $GRAPH.dbg --anno-type row_diff_brwt_coord --greedy -o $GRAPH
ls nobackup/columns/*.annodbg | ./metagraph transform_anno --sketch-precision 0.05 -o $GRAPH

# make GFA (for use with GraphAligner)
./metagraph assemble --unitigs --compacted --to-gfa $GRAPH.dbg -o $GRAPH.gfa

# make PLAST index
./PLAST -i fungi -R assemblies/*.path_cover.fasta.gz -t $NTHREADS -w 13 -a
