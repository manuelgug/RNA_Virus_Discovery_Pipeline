#!/bin/bash -v

source /home/ubuntu/miniconda3/etc/profile.d/conda.sh
conda activate /home/ubuntu/miniconda3/envs/vRhyme_v2

#de metagenoma (ensamble) total

#for f in *_spades-rnaviral 
#do 

#	prefix=$(basename $f _spades-rnaviral)

#	vRhyme -i "$f"/scaffolds.fasta -v ${prefix} -t 32 -o ${prefix}_vRhyme-mgtotal --method longest --verbose --bin_size 1 --cov 0.4 --min_kmer 0 --mems 8 --keep_circ --mask 50 --speed

#done


##de contigs clasificados como virales por blastx, virsorter2 y deepvirfinder  CORREGIR SEGUNDO LOOP

for f in *_ALL_VIRAL_CONTIGS-final
do

        prefix=$(basename $f _ALL_VIRAL_CONTIGS-final)

        vRhyme -i ${prefix}_ALL_VIRAL_CONTIGS-final/${prefix}_ALL_VIRAL_CONTIGS_SEQS.fasta -v ${prefix} -t 32 -o ${prefix}_vRhyme-viral_contigs --method longest --verbose --bin_size 1 --cov 0.4 --min_kmer 0 --mems 8 --keep_circ --mask 50 --speed

done


for f in *_vRhyme-viral_contigs/vRhyme_alternate_bins
do

	for m in *membership.tsv
	do

		alternative_bins_to_fasta.py -i "$f"/"$m" -o "$m"_fasta -f ${prefix}_spades-rnaviral/scaffolds.fasta

	done
done









