#!/bin/bash -v

source /home/ubuntu/miniconda3/etc/profile.d/conda.sh
conda activate /home/ubuntu/miniconda3/envs/virsorter2

for f in *_spades-rnaviral
do 

	prefix=$(basename $f _spades-rnaviral)

	virsorter run -w ${prefix}_virsorter2 -i "$f"/scaffolds.fasta --min-length 0 -j 32 all --verbose --include-groups NCLDV,RNA,ssDNA,lavidaviridae

	grep ">" ${prefix}_virsorter2/final-viral-combined.fa | sed 's/>//g' | sed 's/||.*$//' > ${prefix}_virsorter2/${prefix}_VIRAL_CONTIGS_HEADERS_virsorter2.txt

done
