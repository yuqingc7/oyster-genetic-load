#!/bin/bash -l

## start date
start=`date +%s`

BASEDIR=/local/workdir/yc2644/CV_LM_WGS # Path to base directory.
TARGETDIR=$BASEDIR/bam_ALL_GATK/ # Path to target directory for data store.
BAMLIST=$BASEDIR/bam_ALL_GATK/downsampletarget_bamlist # Path to a list of bam files for downsampling (after overlap clipping and realignment around indels).
SAMTOOLS=/programs/samtools-1.11/bin/samtools # Path to Samtools
PICARD=/programs/picard-tools-2.19.2/picard.jar # Path to GATK
SUM=$BASEDIR/bam_ALL_GATK/depth/ALL_bamlist_depth_per_position_per_sample_summary.tsv # Path to the coverage summary of bam files (before downsampling)
target_cvg=20 # Dataset mean ≈ 13.8×, median ≈ 12.8×
# I used the genome-wide coverage as it is more comparable than the realized coverage.

for SAMPLEBAM in `cat $BAMLIST`; do

    SAMPLEPREFIX=`echo ${SAMPLEBAM%.bam}`
    echo "Sample: $SAMPLEPREFIX"
    SAMPLE=`echo $SAMPLEBAM | cut -d$'_' -f 1-2`
    DEPTH=`grep $SAMPLEPREFIX $SUM | cut -f 2`
    pct=`awk "BEGIN {printf \"%.2f\n\", $target_cvg/$DEPTH}"`
    
    echo "start downsampling"
    if (( $(echo "$pct >= 1" |bc -l) )); 
    then
        echo "Sample $SAMPLE has smaller coverage than the target coverage of $target_cvg"
        #cp $SAMPLEBAM $TARGETDIR$SAMPLEPREFIX'.1.bam'
        echo "--------------------------------------"
    else
        echo "Sample $SAMPLE is being downsampled from $DEPTH to $target_cvg with proportion $pct"
        java -jar $PICARD DownsampleSam \
            I=$TARGETDIR$SAMPLEPREFIX'.bam' \
            O=$TARGETDIR$SAMPLEPREFIX'_down20x.bam' \
            STRATEGY=Chained \
            RANDOM_SEED=123 \
            P=$pct \
            ACCURACY=0.0001
        echo "--------------------------------------"
    fi
done

# end date
end=`date +%s`
runtime=$((end-start))
hours=$((runtime / 3600))
minutes=$(( (runtime % 3600) / 60 ))
seconds=$(( (runtime % 3600) % 60 ))
echo "Runtime: $hours:$minutes:$seconds (hh:mm:ss)"
