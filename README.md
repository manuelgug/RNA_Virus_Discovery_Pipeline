# RNA Virus Discovery Pipeline

This Bash script outlines a comprehensive bioinformatics pipeline I built during my postdoc at Universitat Autònoma de Barcelona for the discovery of RNA viruses from raw sequencing data. The pipeline includes several key steps such as read cleaning, interleaving, dereplication, decontamination, assembly, viral sequence identification, verification, and annotation.

![viral_pipe](https://github.com/manuelgug/RNA_Virus_Discovery_Pipeline/blob/main/img/viral_pipe.png)

## Usage

For my purposes, I created many conda environemnts for all of the components (see commnets in main script). This depends on the user's preferences. However, all must be previously installed regardless.

To run the entire pipeline, execute the following command:

```bash
bash -i -v VIRUS_DISCOVERY_PIPELINE.sh
```
Added the separate scripts as well for debugging.

## Pipeline Steps

1. **Read Cleaning and Filtering**
   - Input: Raw paired-end FASTQ files (`R1` and `R2`).
   - Tool: [fastp](https://github.com/OpenGene/fastp)
   - Output: Trimmed and filtered FASTQ files.

2. **Interleave Reads**
   - Input: Trimmed R1 and R2 FASTQ files.
   - Tool: [BBTools](https://jgi.doe.gov/data-and-tools/bbtools/bb-tools-user-guide/)
   - Output: Interleaved FASTQ files.

3. **Dereplication of Reads**
   - Input: Interleaved FASTQ files.
   - Tool: [CD-HIT](http://weizhongli-lab.org/cd-hit/)
   - Output: Dereplicated FASTQ files.

4. **Decontamination of Reads**
   - Input: Dereplicated FASTQ files.
   - Tool: [BBTools](https://jgi.doe.gov/data-and-tools/bbtools/bb-tools-user-guide/)
   - Output: Decontaminated FASTQ files.

5. **Kraken Taxonomic Classification**
   - Input: Decontaminated FASTQ files.
   - Tool: [Kraken2](https://ccb.jhu.edu/software/kraken2/)
   - Output: Kraken classification results.

6. **Spades Assembly --rnaviral**
   - Input: Decontaminated FASTQ files.
   - Tool: [SPAdes](http://cab.spbu.ru/software/spades/)
   - Output: Assembled contigs.

7. **Diamond BlastX Search**
   - Input: Assembled contigs.
   - Tool: [Diamond](https://github.com/bbuchfink/diamond)
   - Output: Diamond BlastX results and viral contigs.

8. **Virsorter2 Classification**
   - Input: Assembled contigs.
   - Tool: [VirSorter2](https://github.com/jiarong/VirSorter2)
   - Output: VirSorter2 classification results and viral contigs.

9. **DeepVirFinder Classification**
   - Input: Assembled contigs.
   - Tool: [DeepVirFinder](https://github.com/jessieren/DeepVirFinder)
   - Output: DeepVirFinder classification results and viral contigs.

10. **Combine and Extract Significant Contigs**
    - Input: Viral contigs from Diamond, Virsorter2, and DeepVirFinder.
    - Output: Combined viral contigs.

11. **CheckV Validation**
    - Input: Combined viral contigs.
    - Tool: [CheckV](https://github.com/BigDataBiology/CheckV)
    - Output: CheckV validation results.

12. **vRhyme Viral Identification**
    - Input: Combined viral contigs.
    - Tool: [vRhyme](https://github.com/Gabaldonlab/vRhyme)
    - Output: vRhyme viral identification results.

13. **Prokka Annotation**
    - Input: Combined viral contigs.
    - Tool: [Prokka](https://github.com/tseemann/prokka)
    - Output: Annotated viral contigs.

## Note
- Make sure to adjust file paths, database locations, and parameters as needed.
- For prokka, make your own viral proteins db
- Some steps are commented out and need to be corrected based on your specific requirements.

Feel free to customize and enhance the pipeline according to your specific needs.
