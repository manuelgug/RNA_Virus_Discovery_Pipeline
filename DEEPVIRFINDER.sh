

for f in *_spades-rnaviral
do

source /home/ubuntu/miniconda3/etc/profile.d/conda.sh
conda activate /home/ubuntu/miniconda3/envs/dvf

prefix=$(basename $f _spades-rnaviral)

python ../DeepVirFinder/dvf.py -i "$f"/scaffolds.fasta -m ../DeepVirFinder/models/ -o ${prefix}_deepvirfinder/ -c 32

#extrae contigs significativos (p<0.01)
awk -F"\t" '$4<0.01' ${prefix}_deepvirfinder/scaffolds.fasta_gt1bp_dvfpred.txt | awk '{ print $1 }' > ${prefix}_deepvirfinder/${prefix}_VIRAL_CONTIGS_HEADERS_deepvirfinder.txt

done
