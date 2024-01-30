#!/bin/bash -v

source /home/ubuntu/miniconda3/etc/profile.d/conda.sh
conda activate /home/ubuntu/miniconda3/envs/prokka_vir

for f in *_ALL_VIRAL_CONTIGS-final
do

prefix=$(basename $f _ALL_VIRAL_CONTIGS-final)

prokka  --outdir ${prefix}_prokka-viral-contigs --cpus 0 --norrna --notrna --proteins ../viral_proteins_ncbi_19-09-22_db/viral_proteins_ncbi.fasta "$f"/${prefix}_ALL_VIRAL_CONTIGS_SEQS.fasta

done
