#!/bin/bash

METAGRAPH_DIR=~/apps/metagraph/metagraph/build_mla_ng
METAGRAPH=$METAGRAPH_DIR/metagraph
KMC=$METAGRAPH_DIR/KMC/kmc

mkdir -p assemblies

F=$1
PREFIX=assemblies/$(basename $F)

/usr/bin/time -v $METAGRAPH assemble $PREFIX.clean.dbg --path-cover -o $PREFIX.path_cover -v >$PREFIX.pc.log 2>&1
