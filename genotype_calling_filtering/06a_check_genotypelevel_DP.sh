#!/bin/bash

cd ./vcfs

# List all VCFs (invariant + SNP) for all contigs
VCFS=""
for contig in NC_035780.1 NC_035781.1 NC_035782.1 NC_035783.1 NC_035784.1 NC_035785.1 NC_035786.1 NC_035787.1 NC_035788.1 NC_035789.1; do
    VCFS+=" invariant_ALL_${contig}_gatk4filtered.vcf.gz snp_ALL_${contig}_gatk4filtered.vcf.gz"
done

# -------- Overall stats --------
echo "=== Overall genotype-level DP stats ==="
bcftools query -f '[%DP\n]' $VCFS | \
awk '{
    sum+=$1; cnt++;
    if($1<6) b6++;
    if($1<8) b8++;
    if($1<10) b10++;
}
END {
    print "mean_genotype_DP = " sum/cnt;
    print "fraction DP<6  = " b6/cnt;
    print "fraction DP<8  = " b8/cnt;
    print "fraction DP<10 = " b10/cnt;
}'

# -------- Per-sample stats --------
echo "=== Per-sample genotype-level DP stats ==="
samples=($(bcftools query -l $(echo $VCFS | awk '{print $1}')))
for s in "${samples[@]}"; do
    bcftools query -s $s -f '[%DP\n]' $VCFS | \
    awk '{
        sum+=$1; cnt++;
        if($1<6) b6++;
        if($1<8) b8++;
        if($1<10) b10++;
    }
    END {
        mean=sum/cnt;
        printf "%s mean_DP=%.2f  fraction<6=%.3f  fraction<8=%.3f  fraction<10=%.3f\n", "'$s'", mean, b6/cnt, b8/cnt, b10/cnt;
    }'
done
