#!/bin/bash

GRAPH=$1
FILE=$2
OUTPREFIX=$(basename $FILE)
DIR=$(dirname $BASH_SOURCE)

PARAMS="-i $GRAPH.dbg -a $GRAPH.flat.annodbg --align-min-seed-length 15 --align-xdrop 100 --align-min-exact-match 0.0 --print-signature --discovery-fraction 0.0 --align $FILE -v"
CHAIN_PARAMS="--distance 0 --align-post-chain"

/usr/bin/time -v $DIR/metagraph query $PARAMS > $OUTPREFIX.mtgfullnochain.out 2> $OUTPREFIX.mtgfullnochain.log
rm $OUTPREFIX.mtgfullnochain.out.pkl

/usr/bin/time -v $DIR/metagraph align $PARAMS > $OUTPREFIX.mtgnochain.out 2> $OUTPREFIX.mtgnochain.log
rm $OUTPREFIX.mtgnochain.out.pkl

/usr/bin/time -v $DIR/metagraph align $PARAMS $CHAIN_PARAMS > $OUTPREFIX.mtg.out 2> $OUTPREFIX.mtg.log
rm $OUTPREFIX.mtg.out.pkl

