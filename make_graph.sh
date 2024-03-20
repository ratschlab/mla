#!/bin/bash

GRAPH=fungi
NTHREADS=1

# build metagraph index from walk covers
ls nobackup/assemblies/*.path_cover.fasta.gz | /usr/bin/time -v ./metagraph build -k 31 --fwd-and-reverse -o $GRAPH -p $NTHREADS -v >build.log 2>&1

mkdir -p nobackup/columns
mkdir -p tmp
ls nobackup/assemblies/*.path_cover.fasta.gz |  /usr/bin/time -v ./metagraph annotate -i $GRAPH.dbg -o nobackup/columns --anno-filename --separately --coordinates --anno-seq-ends -p $NTHREADS -v >annotate.log 2>&1
for i in 0 1 2; do
    ls nobackup/columns/*.annodbg |  /usr/bin/time -v ./metagraph transform_anno -p $NTHREADS --anno-type row_diff --coordinates -o out --row-diff-stage $i -i $GRAPH.dbg --disk-swap tmp -v >rd_stage_$i.log 2>&1
done
ls nobackup/columns/*.annodbg |  /usr/bin/time -v ./metagraph transform_anno -p $NTHREADS --anno-type column --coordinates -o fungi -v >seq.log 2>&1
ls *reads*.column.annodbg |  /usr/bin/time -v ./metagraph transform_anno -p $NTHREADS -i $GRAPH.dbg --anno-type row_diff_brwt_coord --greedy -o $GRAPH -v >rdbrwt.log 2>&1
ls nobackup/columns/*.annodbg |  /usr/bin/time -v ./metagraph transform_anno --sketch-precision 0.05 -o $GRAPH -v >hll.log 2>&1

# make GFA (for use with GraphAligner)
/usr/bin/time -v ./metagraph assemble --unitigs --compacted --to-gfa $GRAPH.dbg -o $GRAPH.gfa -v >gfa.log 2>&1

# make PLAST index
/usr/bin/time -v PLAST Build -i $GRAPH.plast -R assemblies/*.path_cover.fasta.gz -t $NTHREADS -w 13 -a >plast.log 2>&1
