# Scripts and data for reproducing MLA's evaluation

## Software used
### Running MLA
- MetaGraph (development commit [649c7b4c96c073c249f6092d306967b39e2eafd1](https://github.com/ratschlab/metagraph/tree/649c7b4c96c073c249f6092d306967b39e2eafd1), includes [KMC](https://github.com/karasikov/KMC/tree/0e2ffe0f6fa3564bf7305ac35a803a8e972530e8))

### Simulating reads
- ART Illumina ([v2.5.8](https://www.niehs.nih.gov/research/resources/software/biostatistics/art))
- pbsim3 (commit [v3.0.0](https://github.com/yukiteruono/pbsim3/tree/v3.0.0))
- PacBio ccs ([v6.4.0](https://anaconda.org/bioconda/pbccs))

### Software for parsing read simulation outputs and alignment results
- bbmap ([v38.86](https://sourceforge.net/projects/bbmap/))
- samtools (experiments were run with v1.17)

### Sequence-to-graph alignment tools for comparison
- PLAST (commit [451369eb23e84328ff9334398d185798d2dc5149](https://gitlab.ub.uni-bielefeld.de/gi/plast/-/tree/451369eb23e84328ff9334398d185798d2dc5149))
- GraphAligner ([v1.0.17b](https://anaconda.org/bioconda/graphaligner))

### Additional software for evaluating alignment results
- WGSUniFrac (commit [d5c698ba4699aba168fd29fc00024d655c36183f](https://github.com/KoslickiLab/WGSUniFrac/tree/d5c698ba4699aba168fd29fc00024d655c36183f))
- numpy (v1.26.0)
- pandas (v.2.1.1)

## Setting up the environment
1) Compile MetaGraph from source and install all other required software.
2) Place symlinks for the files `ERRHMM-SEQUEL.model` and `ERRHMM-ONT.model` from `pbsim3` in the root directory, alongside symlinks for the `art_illumina`, `pbsim`, `PLAST`, `GraphAligner`, `metagraph`, and `KMC` executables.
3) Ensure that `samtools` and `reformat.sh` (from `bbmap`) are in your `$PATH`.
4) Download the genomes with the accessions listed in `accession_list` to a directory, with each genome (e.g., if the accession ID is stored in the environment variable `ACC`) in a file named `$ACC.fa`.
5) Download the random entropy source file [`seed2`](https://public.bmi.inf.ethz.ch/resources/mla/seed2) (used to generate query sets)
6) Run `make` to compile `parse_plast`
7) Download the accession-ID augmented taxonomic tree from the `augmented` directory at [here](https://public.bmi.inf.ethz.ch/resources/mla/).

## Constructing a simulated joint assembly graph and the query sets
1) For each genome `$ACC.fa`, run `./make_sample.sh $ACC.fa`
2) Build the MetaGraph, PLAST, and GFA indexes by running `./make_graph.sh`
3) Generate query reads by running `./make_subset.sh`

## Run the alignments and classify the reads
```
for a in query_reads/*.fa; do
    ./map_query_slc.sh $a
    ./map_query_mla.sh $a
    ./map_query_plast.sh $a
    ./map_query_ga.sh $a
done
```
