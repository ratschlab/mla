#!/bin/bash

DIR=$(dirname $BASH_SOURCE)
METAGRAPH="/usr/bin/time -v $DIR/metagraph"
BASENAME=virus40k_ref

if [ -z "$1" ]; then
    T=1
else
    T=$1
fi

find columns/ -type f | grep -vF coord | $METAGRAPH transform_anno -v -p $T --anno-type column_coord --coordinates -o $BASENAME
find columns/ -type f | grep -vF coord | $METAGRAPH transform_anno -v -p $T --anno-type row_diff --coordinates --row-diff-stage 0 -i $BASENAME.dbg -o out --disk-swap swap
find columns/ -type f | grep -vF coord | $METAGRAPH transform_anno -v -p $T --anno-type row_diff --coordinates --row-diff-stage 1 -i $BASENAME.dbg -o out --disk-swap swap
find columns/ -type f | grep -vF coord | $METAGRAPH transform_anno -v -p $T --anno-type row_diff --coordinates --row-diff-stage 2 -i $BASENAME.dbg -o out --disk-swap swap
find columns/ -type f | grep -vF coord | $METAGRAPH transform_anno -v -p $T --anno-type row_diff_coord -i $BASENAME.dbg -o $BASENAME
$METAGRAPH transform_anno -v --anno-type row_diff_brwt_coord -p $T -i $BASENAME.dbg -o $BASENAME $BASENAME.row_diff_coord.annodbg --greedy --fast --subsample 1000000
