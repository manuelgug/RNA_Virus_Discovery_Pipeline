#!/bin/bash -v 


source /home/ubuntu/miniconda3/etc/profile.d/conda.sh
conda activate /home/ubuntu/miniconda3/envs/checkv

for f in *_ALL_VIRAL_CONTIGS-final
do

	prefix=$(basename $f _ALL_VIRAL_CONTIGS-final)

	checkv end_to_end "$f"/${prefix}_ALL_VIRAL_CONTIGS_SEQS.fasta ${prefix}_checkv-viral-contigs  -d ../checkv-db/checkv-db-v1.4/ -t 32

done
