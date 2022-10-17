#!/bin/bash

GFA=$1.gfa
FILE=$2
OUTPREFIX=$(basename $FILE)
GAF=$OUTPREFIX.ga.gaf
DIR=$(dirname $BASH_SOURCE)

/usr/bin/time -v $DIR/GraphAligner -g $GFA -f $FILE -a $GAF -x dbg >$GAF.log 2>&1
$DIR/gaf_to_mtgout.sh $FILE $GAF $GFA
rm $GAF.results.out.pkl
