#!/bin/bash

mkdir -p split_fa
NAME=$(echo "$1" | cut -d"|" -f4); samtools faidx virus_database.fasta $1 >split_fa/$NAME.fa
