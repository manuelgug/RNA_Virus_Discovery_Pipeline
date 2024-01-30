#!/bin/bash -v

####PARA CORRER CONDA DENTRO DE SCRIPT: bash -i -v CLEANING4.sh ######

#limpieza y filtrado de reads

source /home/ubuntu/miniconda3/etc/profile.d/conda.sh
conda activate /home/ubuntu/miniconda3/envs/fastp

for f in individuo*
do

        for i in "$f"/*R1_001.fastq.gz #CUIDADO CON ESTO, CAMBIAR SI ES NECESARIO
        do

	prefix=$(basename $i R1_001.fastq.gz) #CUIDADO CON ESTO, CAMBIAR SI ES NECESARIO

#	printf '\n%s\n' "You have $(zcat "$f"${prefix}R*_001.fastq.gz | echo $((`wc -l`/4))) paired-end raw reads in "$f""

	fastp --in1 "$f"/${prefix}R1_001.fastq.gz  --in2 "$f"/${prefix}R2_001.fastq.gz --out1 "$f"/${prefix}trimmed_R1.fastq.gz --out2 "$f"/${prefix}trimmed_R2.fastq.gz -l 100 -h "$f"/fastp_report.html -w 16

# 	printf '\n%s\n' "You have $(zcat "$f"${prefix}R*_001.fastq.gz | echo $((`wc -l`/4))) paired-end raw reads in "$f""

	done
done

conda deactivate


#interleave reads

source /home/ubuntu/miniconda3/etc/profile.d/conda.sh
conda activate /home/ubuntu/miniconda3/envs/bbtools

for f in individuo*
do
        for i in "$f"/*_trimmed_R1.fastq.gz
	do

	prefix=$(basename $i _trimmed_R1.fastq.gz)

	reformat.sh in1="$f"/${prefix}_trimmed_R1.fastq.gz in2="$f"/${prefix}_trimmed_R2.fastq.gz out=${prefix}_trimmed_R1R2.fastq.gz
	done

done


#dereplicación de reads

for i in *_trimmed_R1R2.fastq.gz
do
	prefix=$(basename $i _trimmed_R1R2.fastq.gz)

	gzip -d "$i"

	cdhit-est -i ${prefix}_trimmed_R1R2.fastq -o ${prefix}_derep_R1R2.fastq -c 1 -M 0 -T 0

	rm *.clstr

done


#descontaminación de reads

source /home/ubuntu/miniconda3/etc/profile.d/conda.sh
conda activate /home/ubuntu/miniconda3/envs/bbtools

for i in *_derep_R1R2.fastq
do

        prefix=$(basename $i _derep_R1R2.fastq)

        bbsplit.sh in="$i" ref=/home/ubuntu/Manuel/contaminants_db/ARCHAEA_genomic.fasta,/home/ubuntu/Manuel/contaminants_db/HUMAN_genomic.fasta,/home/ubuntu/Manuel/contaminants_db/BATS_genomic.fasta,/home/ubuntu/Manuel/contaminants_db/BACTERIA_genomic.fasta basename=out_%.fasta outu=${prefix}_derep_decontam_R1R2.fastq int=t -Xmx200g

        rm out*.fasta
done
