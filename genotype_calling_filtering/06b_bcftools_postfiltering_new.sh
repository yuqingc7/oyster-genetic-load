#!/bin/bash

REF=/workdir/yc2644/CV_LM_WGS/bam_ALL_GATK/CV30_masked_nomtDNA.fasta
INPUT_BAM=/workdir/yc2644/CV_LM_WGS/bam_ALL_GATK/ALL_bamlist
CONTIGS=/workdir/yc2644/CV_LM_WGS/bam_ALL_GATK/chr.list

cd ./vcfs

# Filters a vcf file to remove samples marked exclude, sites that don't pass filters, 
# sites with reference equal to N or alt equal to .

# Remove spanning deletions (*) in ALT

# Genotype-level DP: set genotypes to missing ("./.") at positions with read depth less than 10

# Additional filtering based on missing data and MAF

cat $CONTIGS | parallel -j 10 '
        
        # Invariant VCF
        # Filtering PASS sites (-f .,PASS)
        INPUT_VCF=invariant_ALL_{1}_gatk4filtered.vcf.gz
        SAMPLE_NAME=$(basename "$INPUT_VCF" .vcf.gz)

        # Filtering PASS sites (-f .,PASS) and filling tags with bcftools +fill-tags
        # Keeps sites either explicitly PASS or unfiltered (.)
        bcftools view -f .,PASS $INPUT_VCF -Ou | \
        bcftools +fill-tags -Ou | \
        bcftools filter -S . -e "FMT/DP<10" -Ou | \
        bcftools view -e "ref=\"N\" | F_MISSING > 0.75" -Oz -o ${SAMPLE_NAME}_F_g0.25.vcf.gz
        bcftools index ${SAMPLE_NAME}_F_g0.25.vcf.gz

        # SNP VCF
        INPUT_VCF=snp_ALL_{1}_gatk4filtered.vcf.gz
        SAMPLE_NAME=$(basename "$INPUT_VCF" .vcf.gz)

        # Filtering PASS sites (-f .,PASS) and filling tags with bcftools +fill-tags
        # Keeps sites either explicitly PASS or unfiltered (.). 
        # Remove sites that are monomorphic (.) or spanning deletions (* in ALT)
        # Only biallelic variants (-m2 -M2)
        # Remove sites with >75% missing data and MAF < 0.01
        bcftools view -f .,PASS $INPUT_VCF -Ou | \
        bcftools +fill-tags -Ou | \
        bcftools filter -S . -e "FMT/DP<10" -Ou | \
        bcftools view -m2 -M2 -e "ref=\"N\" | ALT=\".\" | ALT=\"*\" | F_MISSING > 0.75 | MAF < 0.01" -Oz -o ${SAMPLE_NAME}_F_g0.25maf0.01.vcf.gz
        
        bcftools index ${SAMPLE_NAME}_F_g0.25maf0.01.vcf.gz

        # # Stricter filtering based on missing data and MAF
        # # Remove sites with >25% missing data and MAF < 0.01
        # bcftools view -m2 -M2 \
        #         -e "F_MISSING > 0.25" \
        #         ${SAMPLE_NAME}_F_g0.25maf0.01.vcf.gz -Oz -o ${SAMPLE_NAME}_F_g0.75maf0.01.vcf.gz
        # bcftools index ${SAMPLE_NAME}_F_g0.75maf0.01.vcf.gz

' :::: $CONTIGS
