#!/bin/bash

REF=/workdir/yc2644/CV_LM_WGS/bam_ALL_GATK/CV30_masked_nomtDNA.fasta
#INPUT_BAM=/workdir/yc2644/CV_LM_WGS/bam_ALL_GATK/ALL_bamlist
INPUT_BAM=/workdir/yc2644/CV_LM_WGS/bam_ALL_GATK/ALL_down_bamlist
CONTIGS=/workdir/yc2644/CV_LM_WGS/bam_ALL_GATK/chr.list

cd ./vcfs

# filter sites with site-level read depth outside mean - 1*SD and mean + 3*SD range

parallel -j 10 '
    # SNP VCF
    INPUT_VCF=snp_ALL_{1}.vcf.gz
    SAMPLE_NAME=$(basename "$INPUT_VCF" .vcf.gz)

    singularity exec --bind /workdir/yc2644/CV_LM_WGS,/local/storage --pwd $PWD \
        /programs/gatk-4.6.2/gatk.sif gatk VariantFiltration \
        -V $INPUT_VCF \
        -filter "QD < 2.0" --filter-name "QD2" \
        -filter "QUAL < 30" --filter-name "QUAL30" \
        -filter "SOR > 3.0" --filter-name "SOR3" \
        -filter "FS > 60.0" --filter-name "FS60" \
        -filter "MQ < 40.0" --filter-name "MQ40" \
        -filter "MQRankSum < -12.5" --filter-name "MQRankSum-12.5" \
        -filter "ReadPosRankSum < -8.0" --filter-name "ReadPosRankSum-8" \
        -filter "DP > 5896" --filter-name "DP5896" \
        -filter "DP < 215" --filter-name "DP215" \
        -O ${SAMPLE_NAME}_gatk4filtered.vcf.gz \
        > snp_ALL_gatk4filtered_{1}.log 2>&1

    # Invariant VCF
    INPUT_VCF=invariant_ALL_{1}.vcf.gz
    SAMPLE_NAME=$(basename "$INPUT_VCF" .vcf.gz)

    singularity exec --bind /workdir/yc2644/CV_LM_WGS,/local/storage --pwd $PWD \
        /programs/gatk-4.6.2/gatk.sif gatk VariantFiltration \
        -V $INPUT_VCF \
        -filter "DP > 5896" --filter-name "DP5896" \
        -filter "DP < 215" --filter-name "DP215" \
        -O ${SAMPLE_NAME}_gatk4filtered.vcf.gz \
        > invariant_ALL_gatk4filtered_{1}.log 2>&1
' :::: $CONTIGS
