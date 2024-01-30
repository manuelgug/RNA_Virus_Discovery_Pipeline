#!/bin/bash -v


#bam files for binning (total contigs)

#for f in *_spades-rnaviral
#do

#	prefix=$(basename $f _spades-rnaviral)

#	bwa index "$f"/scaffolds.fasta

#	bwa mem  -t 32 "$f"/scaffolds.fasta ${prefix} | samtools sort -o "$f"/${prefix}.bam
 
#	samtools index "$f"/${prefix}.bam

#done


#binning w/metabat2


#source /home/ubuntu/miniconda3/etc/profile.d/conda.sh
#conda activate /home/ubuntu/miniconda3/envs/metabat2

#for f in *_spades-rnaviral
#do

#        prefix=$(basename $f _spades-rnaviral)

#	jgi_summarize_bam_contig_depths --outputDepth "$f"/${prefix}.depth "$f"/${prefix}.bam

#	metabat2 -i "$f"/scaffolds.fasta -a "$f"/${prefix}.depth -o ${prefix}_metabat2_mg-total/ -m 1500 -v -t 32

#done




#bam files for binning (viral contigs)

source /home/ubuntu/miniconda3/etc/profile.d/conda.sh
conda activate /home/ubuntu/miniconda3/envs/metabat2

for f in *_ALL_VIRAL_CONTIGS-final
do

        prefix=$(basename $f _ALL_VIRAL_CONTIGS-final)

	mkdir ${prefix}_viral-contigs-mapping

        bwa index "$f"/${prefix}_ALL_VIRAL_CONTIGS_SEQS.fasta

        bwa mem  -t 32 "$f"/${prefix}_ALL_VIRAL_CONTIGS_SEQS.fasta ${prefix} | samtools sort -o ${prefix}_viral-contigs-mapping/${prefix}.bam

        samtools index ${prefix}_viral-contigs-mapping/${prefix}.bam

done


#binning w/metabat2

for f in *_viral-contigs-mapping
do

        prefix=$(basename $f _viral-contigs-mapping)

        jgi_summarize_bam_contig_depths --outputDepth "$f"/${prefix}.depth "$f"/${prefix}.bam

        metabat2 -i ${prefix}_ALL_VIRAL_CONTIGS-final/${prefix}_ALL_VIRAL_CONTIGS_SEQS.fasta -a "$f"/${prefix}.depth -o ${prefix}_metabat2_viral-contigs/ -v

done
