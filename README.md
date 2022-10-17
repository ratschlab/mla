# Scripts and data for reproducing MetaGraph-MLA's evaluation

## Packages to install
- Conda: environment [opal.yml](opal.yml) (if this does not work, then try [opal_full.yml](opal_full.yml))
- minigraph: [e89a981b2bdf194e749af25b3c85d02f54b2834f](https://github.com/lh3/minigraph/tree/e89a981b2bdf194e749af25b3c85d02f54b2834f)
- MetaGraph: [36d6b7a9d0ac6feef3a7ca4a78da6c5647988751](https://github.com/ratschlab/metagraph/tree/36d6b7a9d0ac6feef3a7ca4a78da6c5647988751)
- GraphAligner: 1.0.13 (linked in opal.yml)
- GetBlunted: [19ac4ef901cc24a744dc1fb6fa8c5921252f437e](https://github.com/vgteam/GetBlunted/tree/19ac4ef901cc24a744dc1fb6fa8c5921252f437e)
- bbmap: 38.86
- samtools: 1.15.1
- ART: [`art_src_MountRainier_Linux`](https://www.niehs.nih.gov/research/resources/software/biostatistics/art/index.cfm)
- pbsim: [e014b1dd40e87a8799346a9835d70a4da3dc857c](https://github.com/pfaucon/PBSIM-PacBio-Simulator/tree/e014b1dd40e87a8799346a9835d70a4da3dc857c)

## Large file access
Pre-built graph indexes, read sets, and the taxonomic tree used for these experiments are available [here](https://drive.google.com/drive/folders/1NCNuxecNF8BErtSmYW-9TXRgTdva37ZB).

## Instructions for building graphs and aligning reads
0) Set the number of threads according to your needs (in this example, it's set to 1)
```
THREADS=1
```
1) Simulate reads from the reference genomes
```
awk -F"[/.]" '{print $2"."$3}' col_names.shuf.head41026.txt | while read NAME; do ./extract.sh $NAME; ./make_sample.sh split_fa/$NAME; done
```
2) Build MetaGraph index from the simulated reads
```
cat col_names.shuf.head41026.txt | ./metagraph build -k 31 --mode canonical --mem-cap-gb 15 -v -o virus40k -p $THREADS >graph.log 2>&1
./metagraph assemble --primary-kmers -p $THREADS -o virus40k_primary -v virus40k.dbg >assemble.log 2>&1
./metagraph build -k 31 -o virus40k_primary virus40k_primary.fasta.gz --mem-cap-gb 15 -v -p $THREADS virus40k_primary.fasta.gz --mode primary >primary.log 2>&1
mkdir -p columns
find samples/ -type f | grep -F fasta | ./metagraph annotate -i virus40k_primary.dbg -o columns --anno-filename --separately -p $THREADS -v > annotate.log 2>&1
find columns/ -type f | ./metagraph transform_anno -o virus40k_primary --anno-type flat -p $THREADS -v >anno_conv.log 2>&1
./metagraph transform_anno --sketch-precision 0.05 -o virus40k_primary -v virus40k_primary.column.annodbg > hll.log 2>&1
```
3) Build MetaGraph index with coordinates from the reference genomes
```
mkdir -p ref_columns
find split_fa/ -type f | ./metagraph build -k 31 --mem-gap-gb 15 -v -o virus40k_ref -p $THREADS >ref.log 2>&1
find split_fa/ -type f | ./metagraph annotate -i virus40k_ref.dbg -o ref_columns --anno-filename --separarely --coordinates -p $THREADS -v > ref_annotate.log 2>&1
./transform_anno.sh $THREADS
```
4) Convert MetaGraph index to GFA (DBG and variation graphs)
```
./metagraph assemble --to-gfa -o virus40k --unitigs -v virus40k.dbg -p $THREADS
./get_blunted -p virus40k.provenance.txt virus40k.gfa > virus40k.blunt.gfa 2> virus40k.blunt.gfa.log
```
5) Simulate test reads
```
./make_test.sh
```
6) Run alignments
```
for a in test_reads.hifi.shuf.fa.head2000.fa  test_reads.pacbio.shuf.fa.head2000.fa  test_reads.shuf.fa.head2000.fa; do
  ./run_metagraph.sh virus40k_primary $a
  ./run_graphaligner.sh virus40k $a
  ./run_minigraph.sh virus40k.blunt $a
  ./metagraph align -v -i virus40k_ref.dbg -a virus40k_ref.column_coord.annodbg --align-min-seed-length 15 --align-min-exact-match 0.0 $a > $a.tcg.out 2> $a.tcg.log
done
```

## Running the Jupyter Notebook
By default, the provided notebook ([tax_analysis.ipynb](tax_analysis.ipynb)) loads pre-parsed arrays from the provided .pkl files. After re-running a tool, please remove the corresponding pkl file to reparse the output.
