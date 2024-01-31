#!/bin/bash

PARAMS="-g fungi.gfa -a ga_jointgraph/$(basename $1).gaf -x dbg -f $1"

mkdir -p ga_jointgraph

/usr/bin/time -v ./GraphAligner $PARAMS >ga_jointgraph/$(basename $1).log 2>&1

