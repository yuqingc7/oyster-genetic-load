#!/bin/bash

## start date
start=`date +%s`

#REF=CV30_masked_nomtDNA.fasta
#INPUT_BAM=/workdir/yc2644/CV_LM_WGS/bam_ALL_GATK/ALL_bamlist
INPUT_BAM=/workdir/yc2644/CV_LM_WGS/bam_ALL_GATK/ALL_down_bamlist
CONTIGS=/workdir/yc2644/CV_LM_WGS/bam_ALL_GATK/chr.list

cd ./genomicsdb

cat $CONTIGS | parallel -j 10 '
    CONTIG={}

    MAP=ALL_sample_map_${CONTIG}.txt
    > "$MAP"

    while read bam; do
        SAMPLE=$(basename "$bam" .F.bam)
        echo -e "${SAMPLE}\t/workdir/yc2644/CV_LM_WGS/bam_ALL_GATK/gvcfs/${SAMPLE}.${CONTIG}.g.vcf.gz" >> "$MAP"
    done < '"$INPUT_BAM"'

    singularity exec --bind /workdir/yc2644/CV_LM_WGS,/local/storage --pwd $PWD \
        /programs/gatk-4.6.2/gatk.sif gatk GenomicsDBImport \
        --sample-name-map "$MAP" \
        --batch-size 50 --bypass-feature-reader \
        --genomicsdb-workspace-path ALL_${CONTIG}_genomicsdb \
        -L "$CONTIG" \
        --reader-threads 2
'

# end date
end=`date +%s`
runtime=$((end-start))
hours=$((runtime / 3600))
minutes=$(( (runtime % 3600) / 60 ))
seconds=$(( (runtime % 3600) % 60 ))
echo "Runtime: $hours:$minutes:$seconds (hh:mm:ss)"
