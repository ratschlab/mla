# Scripts and data for reproducing MLA's evaluation

## Software used
### Running MLA
- MetaGraph (development commit [bd39d9594e77f276e674033b52d9b26ec3a281e3](https://github.com/ratschlab/metagraph/tree/bd39d9594e77f276e674033b52d9b26ec3a281e3), includes [KMC](https://github.com/karasikov/KMC/tree/0e2ffe0f6fa3564bf7305ac35a803a8e972530e8))

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
- WGSUniFrac (commit [d5c698ba4699aba168fd29fc00024d655c36183f](https://github.com/KoslickiLab/WGSUniFrac/tree/d5c698ba4699aba168fd29fc00024d655c36183f), included here)
- numpy (v1.26.0)
- pandas (v.2.1.1)

## Setting up the environment
1) To install most of the required software for the evaluation, set up a `conda` environment using the provided `environment.yml` file: `conda env create -f environment.yml`
2) Activate the environment: `conda activate mla`
3) Download pre-compiled binaries of `metagraph`, `PLAST`, `kmc`, and `parse_plast` from [here](https://public.bmi.inf.ethz.ch/resources/mla/software/) and place them in your working directory.
4) Download the genomes from [here](https://public.bmi.inf.ethz.ch/resources/mla/references/) to a directory named `references`. A list of accessions is in `accession_list`
5) Download the random entropy source file [`seed2`](https://public.bmi.inf.ethz.ch/resources/mla/seed2) (used to generate query sets)
6) Download the accession-ID augmented taxonomic tree from the `augmented` directory [here](https://public.bmi.inf.ethz.ch/resources/mla/)

## Constructing a simulated joint assembly graph and the query sets
1) Simulate reads for each genome:
   ```
   for a in references/*.fa; do ./make_sample.sh $a; done
   for a in illumina hifi clr ont; do ./make_subset.sh $a; done
   ```
3) Build the MetaGraph, PLAST, and GFA indexes by running `./make_graph.sh`. In this script, you can set the number of threads in the variable `$NTHREADS`.
4) Generate query reads by running `./make_subset.sh`

## Run the alignments and classify the reads
```
for a in query_reads/*.fa; do
    ./map_query_sca.sh $a
    ./map_query_mla.sh $a
    ./map_query_plast.sh $a
    ./map_query_ga.sh $a
done
```

## Notes
- To compile `parse_plast.cpp` yourself, we have provided a `Makefile`.
- To compile `PLAST` yourself, we have provided a template `CMakeLists.txt` file in `plast_cmake`. Please edit it to point to the `include` directory and static lib of `Bifrost`.
- To compile MetaGraph from source, follow the instructions [here](https://metagraph.ethz.ch/static/docs/installation.html#install-from-source). Remember to checkout the commit listed above from the `hm/aln_alt_label_change` branch.
- Run `metagraph align` to view the help menu listing alignment parameters. To list a more advanced set of parameters, run `metagraph align --advanced`.
