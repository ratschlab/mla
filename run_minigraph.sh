#!/bin/bash

GFA=$1.gfa
FILE=$2
OUTPREFIX=$(basename $FILE)
GAF=$OUTPREFIX.gmg.gaf
DIR=$(dirname $BASH_SOURCE)

/usr/bin/time -v $DIR/minigraph $GFA $FILE > $GAF 2>$GAF.log
$DIR/gaf_to_mtgout.sh $FILE $GAF $GFA
rm $GAF.results.out.pkl
