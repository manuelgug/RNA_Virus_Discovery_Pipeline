#!/bin/bash -v

source /home/ubuntu/miniconda3/etc/profile.d/conda.sh
conda activate /home/ubuntu/miniconda3/envs/diamond

for f in *_spades-rnaviral
do

prefix=$(basename $f _spades-rnaviral)

mkdir ${prefix}_diamond

diamond blastx -d ../viral_proteins_ncbi_19-09-22_db/viral_prots.dmnd -q "$f"/scaffolds.fasta -o ${prefix}_diamond/${prefix}_diamond -t /home/ubuntu/Manuel/workig_dir/${prefix}_diamond -p 32 -f6 --range-culling -F 15

#extract viral contigs headers
sort -u -t "$(printf "\t")" -k1,1 ${prefix}_diamond/${prefix}_diamond | awk '{print $1}' > ${prefix}_diamond/${prefix}_diamond_VIRAL_CONTIGS_HEADERS_diamond.txt

done
