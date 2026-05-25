#!/bin/bash

REF=/workdir/yc2644/CV_LM_WGS/bam_ALL_GATK/CV30_masked_nomtDNA.fasta
#INPUT_BAM=/workdir/yc2644/CV_LM_WGS/bam_ALL_GATK/ALL_bamlist
INPUT_BAM=/workdir/yc2644/CV_LM_WGS/bam_ALL_GATK/ALL_down_bamlist
CONTIGS=/workdir/yc2644/CV_LM_WGS/bam_ALL_GATK/chr.list

cd ./vcfs

cat $CONTIGS | parallel -j 10 '
    CONTIG={}

    # Invariant sites
    if [ ! -f invariant_ALL_${CONTIG}.vcf.gz.tbi ]; then
        singularity exec --bind /workdir/yc2644/CV_LM_WGS,/local/storage --pwd $PWD \
            /programs/gatk-4.6.2/gatk.sif gatk SelectVariants \
            -V allsites_ALL_${CONTIG}.vcf.gz \
            -select-type NO_VARIATION \
            -O invariant_ALL_${CONTIG}.vcf.gz > "invariant_ALL_${CONTIG}.log" 2>&1
    else
        echo "Skipping invariant_ALL_${CONTIG}.vcf.gz (already exists)"
    fi

    # SNPs
    if [ ! -f snp_ALL_${CONTIG}.vcf.gz.tbi ]; then
        singularity exec --bind /workdir/yc2644/CV_LM_WGS,/local/storage --pwd $PWD \
            /programs/gatk-4.6.2/gatk.sif gatk SelectVariants \
            -V allsites_ALL_${CONTIG}.vcf.gz \
            -select-type SNP \
            -O snp_ALL_${CONTIG}.vcf.gz > "snp_ALL_${CONTIG}.log" 2>&1
    else
        echo "Skipping snp_ALL_${CONTIG}.vcf.gz (already exists)"
    fi
'
