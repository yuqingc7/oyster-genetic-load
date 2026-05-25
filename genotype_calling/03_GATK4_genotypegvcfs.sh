#!/bin/bash

REF=/workdir/yc2644/CV_LM_WGS/bam_ALL_GATK/CV30_masked_nomtDNA.fasta
#INPUT_BAM=/workdir/yc2644/CV_LM_WGS/bam_ALL_GATK/ALL_bamlist
INPUT_BAM=/workdir/yc2644/CV_LM_WGS/bam_ALL_GATK/ALL_down_bamlist
#CONTIGS=/workdir/yc2644/CV_LM_WGS/bam_ALL_GATK/chr.list
CONTIGS=/workdir/yc2644/CV_LM_WGS/bam_ALL_GATK/chr_rerun.list

cd ./genomicsdb

cat $CONTIGS | parallel -j 3 '
    CONTIG={}
    LOGFILE="../vcfs/allsites_ALL_${CONTIG}.log"

    singularity exec --bind /workdir/yc2644/CV_LM_WGS,/local/storage --pwd $PWD \
        /programs/gatk-4.6.2/gatk.sif gatk GenotypeGVCFs \
        -R '"$REF"' \
        -V gendb://ALL_${CONTIG}_genomicsdb \
        -all-sites -L ${CONTIG} -O ../vcfs/allsites_ALL_${CONTIG}.vcf.gz  > "$LOGFILE" 2>&1
'
