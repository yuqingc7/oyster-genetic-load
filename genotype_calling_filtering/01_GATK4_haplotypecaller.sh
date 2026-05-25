#!/bin/bash

REF=CV30_masked_nomtDNA.fasta
#INPUT_BAM=ALL_bamlist
INPUT_BAM=downsample_bamlist
CONTIGS=chr.list

mkdir -p gvcfs gvcfs_logs

# parallel -j 40 --eta '
# bam={}
# SAMPLE_NAME=$(basename "$bam" .F.bam)
# while read CONTIG; do
#     OUTFILE="gvcfs/${SAMPLE_NAME}.${CONTIG}.g.vcf.gz"
#     LOGFILE="gvcfs_logs/${SAMPLE_NAME}.${CONTIG}.log"

#     singularity exec --bind /workdir/yc2644/CV_LM_WGS,/local/storage --pwd $PWD /programs/gatk-4.6.2/gatk.sif gatk HaplotypeCaller \
#         -R '"$REF"' \
#         -I "$bam" \
#         -L "$CONTIG" \
#         -O "$OUTFILE" \
#         -ERC GVCF \
#         -G AS_StandardAnnotation > "$LOGFILE" 2>&1
# done < '"$CONTIGS"'
# ' :::: "$INPUT_BAM"

# Loop over each BAM
while read -r bam; do
    SAMPLE_NAME=$(basename "$bam" .F.bam)
    
    # Run contigs in parallel
    cat "$CONTIGS" | parallel -j 10 '
    CONTIG={}
    OUTFILE="gvcfs/'"$SAMPLE_NAME"'.${CONTIG}.g.vcf.gz"
    LOGFILE="gvcfs_logs/'"$SAMPLE_NAME"'.${CONTIG}.log"

    singularity exec --bind /workdir/yc2644/CV_LM_WGS,/local/storage \
        --pwd $PWD /programs/gatk-4.6.2/gatk.sif gatk HaplotypeCaller \
        -R '"$REF"' \
        -I '"$bam"' \
        -L "$CONTIG" \
        -O "$OUTFILE" \
        -ERC GVCF \
        -G AS_StandardAnnotation > "$LOGFILE" 2>&1
    '
done < "$INPUT_BAM"

# -ERC GVCF: Reference model emitted with condensed non-variant blocks, i.e. the GVCF format.
# -G StandardAnnotation: Add standard annotations to the output VCF. Enabled for this tool by default
# -G AS_StandardAnnotation: Add allele-specific annotations to the output VCF.
