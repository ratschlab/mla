#!/bin/bash

INFILE=$1
INRES=$2
GFA=$3
GRAPH=$(echo $GFA | cut -d"." -f1)_primary
DIR=$(dirname $BASH_SOURCE)

python3 $DIR/get_seqs_from_gaf.py $GFA $INFILE $INRES > $INRES.fa
$DIR/metagraph query -i $GRAPH.dbg -a $GRAPH.flat.annodbg --discovery-fraction 0.0 --print-signature $INRES.fa > $INRES.results.out
