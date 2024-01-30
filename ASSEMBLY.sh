#!/bin/bash -v

source /home/ubuntu/miniconda3/etc/profile.d/conda.sh
conda activate /home/ubuntu/miniconda3/envs/spades

for f in *_derep_decontam_R1R2.fastq
do
	spades.py --12 "$f" -t 32 --rnaviral -o "$f"_spades-rnaviral
done
