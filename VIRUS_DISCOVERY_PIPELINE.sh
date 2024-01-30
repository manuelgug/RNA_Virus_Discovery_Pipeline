#!/bin/bash -v

#-------------------------------------------------------------------------------------------------------

#Author: Dr. Manuel García Ulloa Gamiz, 2022

#Input: RAW PAIRED-END ILLUMINA READS
#Main outputs: (mostly) RNA VIRAL COMMUNITY COMPOSITION, METAGENOMIC ASSEMBLIES, VIRAL BINNING

####QUICK COMMAND: bash -i -v VIRUS_DISCOVERY_PIPELINE.sh (verify input naming first!)######

#note: some versions of libraries used by different software conflict with each other, so individual conda environments were made for each software
#-------------------------------------------------------------------------------------------------------



#---READ CLEANING AND FILTERING---

#notes: folders should contain paired-end reads (R1 and R2 files) and share a common name pattern (sample1, sample2 [common pattern is sample*]; _reads_2345, _sample_zzz [common pattern is _*])
#change minimum length (-l) as needed

source /home/ubuntu/miniconda3/etc/profile.d/conda.sh
conda activate /home/ubuntu/miniconda3/envs/fastp

for f in _________ #replace underscores with common name pattern of read folders
do
        for i in "$f"/*R1_001.fastq.gz #change if necessary according name of read files
        do
		prefix=$(basename $i R1_001.fastq.gz) #change if necessary according name of read files
		fastp --in1 "$f"/${prefix}R1_001.fastq.gz  --in2 "$f"/${prefix}R2_001.fastq.gz --out1 "$f"/${prefix}trimmed_R1.fastq.gz --out2 "$f"/${prefix}trimmed_R2.fastq.gz -l 20 -h "$f"/fastp_report.html -w 16
	done
done
conda deactivate



#---INTERLEAVE READS---

source /home/ubuntu/miniconda3/etc/profile.d/conda.sh
conda activate /home/ubuntu/miniconda3/envs/bbtools

for f in _________ #replace underscores with common name pattern of read folders
do
        for i in "$f"/*_trimmed_R1.fastq.gz
	do
		prefix=$(basename $i _trimmed_R1.fastq.gz)
		reformat.sh in1="$f"/${prefix}_trimmed_R1.fastq.gz in2="$f"/${prefix}_trimmed_R2.fastq.gz out=${prefix}_trimmed_R1R2.fastq.gz
	done
done
conda deactivate



#---DEREPLICATION OF READS---

#note: automatically tuned to 100% identical reads (-c 1). change as needed

for i in *_trimmed_R1R2.fastq.gz
do
	prefix=$(basename $i _trimmed_R1R2.fastq.gz)
	gzip -d "$i"
	cdhit-est -i ${prefix}_trimmed_R1R2.fastq -o ${prefix}_derep_R1R2.fastq -c 1 -M 0 -T 0
	rm *.clstr
done



#---DECONTAMINATION OF READS---

#needs absolute paths of contaminant database(s) (genomic sequences in fasta format). in this case, human and bacteria are set. Archaea and bat databases are also already available in the home/ubuntu/Manuel/contaminants_db/ folder

#note: don't perform this step if absolute fraction of viuses in a sample needs to be known
#note: this step takes time and there are often a fair chunk of contaminant sequences left. a better and faster solution alternative be kraken filtering (https://genozip.readthedocs.io/kraken.html, not yet applied in this script), just don't get rid of Unclassified reads as they may be unknown viruses

source /home/ubuntu/miniconda3/etc/profile.d/conda.sh
conda activate /home/ubuntu/miniconda3/envs/bbtools

for i in *_derep_R1R2.fastq
do
        prefix=$(basename $i _derep_R1R2.fastq)
        bbsplit.sh in="$i" ref=/home/ubuntu/Manuel/contaminants_db/HUMAN_genomic.fasta,/home/ubuntu/Manuel/contaminants_db/BACTERIA_genomic.fasta basename=out_%.fasta outu=${prefix}_derep_decontam_R1R2.fastq int=t -Xmx200g
        rm out*.fasta
done
conda deactivate



#---COMMUNITY COMPOSITION---

#kraken2 database MINUSB is set. change as needed 

#note: check input file name if previous decontamination step is not used and instead switched to posterior kraken filtering

for f in *_derep_decontam_R1R2.fastq
do
	prefix=$(basename $f _derep_decontam_R1R2.fastq)
	reformat.sh in="$f" out1=${prefix}_R1-temp.fastq out2=${prefix}_R2-temp.fastq
	kraken2 --memory-mapping --db /home/ubuntu/Manuel/kraken_db --threads 32 --paired ${prefix}_R1-temp.fastq ${prefix}_R2-temp.fastq --report  ${prefix}-kraken-report_MINUSB.txt --output ${prefix}_kraken-out_MINUSB.output
	rm *temp*
	mkdir ${prefix}_derep_decontam_R1R2.fastq_KRAKEN
	mv *kraken* ${prefix}_derep_decontam_R1R2.fastq_KRAKEN/.
done



#---KRAKEN FILTERING (decontamination)---




#---METAGENOMIC ASSEMBLY---

#using the option --rnaviral often results in entire RNA viral genomes

source /home/ubuntu/miniconda3/etc/profile.d/conda.sh
conda activate /home/ubuntu/miniconda3/envs/spades

for f in *_derep_decontam_R1R2.fastq
do
	spades.py --12 "$f" -t 32 --rnaviral -o "$f"_spades-rnaviral
done
conda deactivate



#---VIRAL ASSIGNMENT #1: DIAMOND---

#used the complete viral protein database from ncbi. change as needed

source /home/ubuntu/miniconda3/etc/profile.d/conda.sh
conda activate /home/ubuntu/miniconda3/envs/diamond

for f in *_spades-rnaviral
do
	prefix=$(basename $f _spades-rnaviral)
	mkdir ${prefix}_diamond
	diamond blastx -d ../viral_proteins_ncbi_19-09-22_db/viral_prots.dmnd -q "$f"/scaffolds.fasta -o ${prefix}_diamond/${prefix}_diamond -t /home/ubuntu/Manuel/workig_dir/${prefix}_diamond -p 32 -f6 --range-culling -F 15
	sort -u -t "$(printf "\t")" -k1,1 ${prefix}_diamond/${prefix}_diamond | awk '{print $1}' > ${prefix}_diamond/${prefix}_diamond_VIRAL_CONTIGS_HEADERS_diamond.txt #extract headers from viral contigs
done
conda deactivate



#---VIRAL ASSIGNMENT #2: VIRSORTER2---

source /home/ubuntu/miniconda3/etc/profile.d/conda.sh
conda activate /home/ubuntu/miniconda3/envs/virsorter2

for f in *_spades-rnaviral
do 
	prefix=$(basename $f _spades-rnaviral)
	virsorter run -w ${prefix}_virsorter2 -i "$f"/scaffolds.fasta --min-length 0 -j 32 all --verbose --include-groups NCLDV,RNA,ssDNA,lavidaviridae
	grep ">" ${prefix}_virsorter2/final-viral-combined.fa | sed 's/>//g' | sed 's/||.*$//' > ${prefix}_virsorter2/${prefix}_VIRAL_CONTIGS_HEADERS_virsorter2.txt # extract headers from viral contigs
done

conda deactivate



#---VIRAL ASSIGNMENT #3: DEEPVIRFINDER---

source /home/ubuntu/miniconda3/etc/profile.d/conda.sh
conda activate /home/ubuntu/miniconda3/envs/dvf

for f in *_spades-rnaviral
do
	prefix=$(basename $f _spades-rnaviral)
	python ../DeepVirFinder/dvf.py -i "$f"/scaffolds.fasta -m ../DeepVirFinder/models/ -o ${prefix}_deepvirfinder/ -c 32
	awk -F"\t" '$4<0.01' ${prefix}_deepvirfinder/scaffolds.fasta_gt1bp_dvfpred.txt | awk '{ print $1 }' > ${prefix}_deepvirfinder/${prefix}_VIRAL_CONTIGS_HEADERS_deepvirfinder.txt #extract headers from  significant (p<0.01) viral contigs
done
conda deactivate



#---EXTRACT UNIQUE VIRAL CONTIGS FROM THE 3 VIRAL ASSIGNMENT METHODS---

for f in *_spades-rnaviral
do
	prefix=$(basename "$f" _spades-rnaviral)
	mkdir ${prefix}_ALL_VIRAL_CONTIGS-final
	cp ${prefix}*/*VIRAL_CONTIGS_HEADERS_*.txt ${prefix}_ALL_VIRAL_CONTIGS-final/.
	cat ${prefix}_ALL_VIRAL_CONTIGS-final/*txt | sort | uniq > ${prefix}_ALL_VIRAL_CONTIGS-final/${prefix}_ALL_VIRAL_CONTIGS_HEADERS.ccc
	seqtk subseq "$f"/scaffolds.fasta ${prefix}_ALL_VIRAL_CONTIGS-final/${prefix}_ALL_VIRAL_CONTIGS_HEADERS.ccc > ${prefix}_ALL_VIRAL_CONTIGS-final/${prefix}_ALL_VIRAL_CONTIGS_SEQS.fasta
done



#---CHECK FOR COMPLETE VIRAL GENOMES---

source /home/ubuntu/miniconda3/etc/profile.d/conda.sh
conda activate /home/ubuntu/miniconda3/envs/checkv

for f in *_ALL_VIRAL_CONTIGS-final
do
	prefix=$(basename $f _ALL_VIRAL_CONTIGS-final)
	checkv end_to_end "$f"/${prefix}_ALL_VIRAL_CONTIGS_SEQS.fasta ${prefix}_checkv-viral-contigs  -d /home/ubuntu/Manuel/checkv-db/checkv-db-v1.4/ -t 32
done
conda deactivate



#---VIRAL BINNING---

source /home/ubuntu/miniconda3/etc/profile.d/conda.sh
conda activate /home/ubuntu/miniconda3/envs/vRhyme_v2

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

rm *membership.tsv


#---ANNOTATION---

#!/bin/bash -v

source /home/ubuntu/miniconda3/etc/profile.d/conda.sh
conda activate /home/ubuntu/miniconda3/envs/prokka_vir

for f in *_ALL_VIRAL_CONTIGS-final
do

prefix=$(basename $f _ALL_VIRAL_CONTIGS-final)

prokka  --outdir ${prefix}_prokka-viral-contigs --cpus 0 --norrna --notrna --proteins ../viral_proteins_ncbi_19-09-22_db/viral_proteins_ncbi.fasta "$f"/${prefix}_ALL_VIRAL_CONTIGS_SEQS.fasta

done
