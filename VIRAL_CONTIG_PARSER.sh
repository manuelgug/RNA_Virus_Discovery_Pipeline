


for f in *_spades-rnaviral
do

prefix=$(basename "$f" _spades-rnaviral)

mkdir ${prefix}_ALL_VIRAL_CONTIGS-final

cp ${prefix}*/*VIRAL_CONTIGS_HEADERS_*.txt ${prefix}_ALL_VIRAL_CONTIGS-final/.

cat ${prefix}_ALL_VIRAL_CONTIGS-final/*txt | sort | uniq > ${prefix}_ALL_VIRAL_CONTIGS-final/${prefix}_ALL_VIRAL_CONTIGS_HEADERS.ccc

seqtk subseq "$f"/scaffolds.fasta ${prefix}_ALL_VIRAL_CONTIGS-final/${prefix}_ALL_VIRAL_CONTIGS_HEADERS.ccc > ${prefix}_ALL_VIRAL_CONTIGS-final/${prefix}_ALL_VIRAL_CONTIGS_SEQS.fasta

done



