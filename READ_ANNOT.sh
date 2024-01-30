#!/bin/bash -v


source /home/ubuntu/miniconda3/etc/profile.d/conda.sh
conda activate /home/ubuntu/miniconda3/envs/bbtools

for f in *_derep_decontam_R1R2.fastq
do

	prefix=$(basename $f _derep_decontam_R1R2.fastq)

	reformat.sh in="$f" out1=${prefix}_R1-temp.fastq out2=${prefix}_R2-temp.fastq

	kraken2 --memory-mapping --db /home/ubuntu/Manuel/kraken_db --threads 32 --paired ${prefix}_R1-temp.fastq ${prefix}_R2-temp.fastq --report  ${prefix}-kraken-report_MINUSB.txt --output ${prefix}_kraken-out_MINUSB.output

	rm *temp*

	mkdir ${prefix}_derep_decontam_R1R2.fastq_KRAKEN

	mv *kraken* ${prefix}_derep_decontam_R1R2.fastq_KRAKEN/.

done

