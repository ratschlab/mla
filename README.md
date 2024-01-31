# Scripts and data for reproducing MLA's evaluation

## Software used
- MetaGraph (development commit [649c7b4c96c073c249f6092d306967b39e2eafd1](https://github.com/ratschlab/metagraph/tree/649c7b4c96c073c249f6092d306967b39e2eafd1), includes [KMC](https://github.com/karasikov/KMC/tree/0e2ffe0f6fa3564bf7305ac35a803a8e972530e8))
- ART Illumina ([v2.5.8](https://www.niehs.nih.gov/research/resources/software/biostatistics/art))
- pbsim3 (commit [v3.0.0](https://github.com/yukiteruono/pbsim3/tree/v3.0.0))
- PacBio ccs ([v6.4.0](https://anaconda.org/bioconda/pbccs))
- PLAST (commit [451369eb23e84328ff9334398d185798d2dc5149](https://gitlab.ub.uni-bielefeld.de/gi/plast/-/tree/451369eb23e84328ff9334398d185798d2dc5149))
- GraphAligner ([v1.0.17b](https://anaconda.org/bioconda/graphaligner))
- bbmap ([v38.86](https://sourceforge.net/projects/bbmap/))
- samtools (experiments were run with v1.17)

## Setting up the environment
1) Compile MetaGraph from source and install all other required software.
2) Place symlinks for the files `ERRHMM-SEQUEL.model` and `ERRHMM-ONT.model` from `pbsim3` in the root directory, alongside symlinks for the `art_illumina`, `pbsim`, `PLAST`, `GraphAligner`, `metagraph`, and `KMC` executables.
3) Ensure that `samtools` and `reformat.sh` (from `bbmap`) are in your `$PATH`.
4) Download the genomes with the accessions listed in `accession_list` to a directory, with each genome (e.g., if the accession ID is stored in the environment variable `ACC`) in a file named `$ACC.fa`.
5) Download the random entropy source file [`seed2`](https://public.bmi.inf.ethz.ch/resources/mla/seed2) (used to generate query sets)
6) Run `make` to compile `parse_plast`

## Constructing a simulated joint assembly graph and the query sets
1) For each genome `$ACC.fa`, run `./make_sample.sh $ACC.fa`
2) Build the MetaGraph, PLAST, and GFA indexes by running `./make_graph.sh`
3) Generate query reads by running `./make_subset.sh`
