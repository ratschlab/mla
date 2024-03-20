#!/bin/bash

OUTPREFIX="ga_jointgraph/$(basename $1)"
PARAMS="-g fungi.gfa -a $OUTPREFIX.gaf -x dbg -f $1"

mkdir -p ga_jointgraph

/usr/bin/time -v GraphAligner $PARAMS >$OUTPREFIX.log 2>&1
./classify_ga.py $OUTPREFIX.gaf $1 >$OUTPREFIX.gaf.wgsunifrac.sweep.tsv 2>$OUTPREFIX.gaf.wgsunifrac.sweep.log
