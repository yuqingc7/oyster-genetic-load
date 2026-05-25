#!/bin/bash

cd ./vcfs

for f in *_F*.vcf.gz; do
     count=$(bcftools index -n "$f")
     echo -e "$f\t$count"
done >> vcf_site_counts.tsv

ls invariant_ALL_*_gatk4filtered_F_g0.25.vcf.gz | sort > invariant_ALL_F_g0.25_vcfs.txt
#ls snp_ALL_*_gatk4filtered_F.vcf.gz | sort > snp_ALL_F_vcfs.txt
ls snp_ALL_*_gatk4filtered_F_g0.25maf0.01.vcf.gz | sort > snp_ALL_F_g0.25maf0.01_vcfs.txt
#ls snp_ALL_*_gatk4filtered_F_g0.75maf0.01.vcf.gz | sort > snp_ALL_F_g0.75maf0.01_vcfs.txt

# Concatenate contigs to create genome-wide VCFs
# Invariant sites
bcftools concat -Oz -o /workdir/yc2644/CV_LM_WGS/vcf_ALL_GATK/invariant_ALL_F_g0.25.vcf.gz -f invariant_ALL_F_g0.25_vcfs.txt --threads 4 &

# SNP sites
#bcftools concat -Oz -o /workdir/yc2644/CV_LM_WGS/vcf_ALL_GATK/snp_ALL_F_g0.75maf0.01.vcf.gz -f snp_ALL_F_g0.75maf0.01_vcfs.txt --threads 4 &
bcftools concat -Oz -o /workdir/yc2644/CV_LM_WGS/vcf_ALL_GATK/snp_ALL_F_g0.25maf0.01.vcf.gz -f snp_ALL_F_g0.25maf0.01_vcfs.txt --threads 4 &
#bcftools concat -Oz -o /workdir/yc2644/CV_LM_WGS/vcf_ALL_GATK/snp_ALL_F.vcf.gz -f snp_ALL_F_vcfs.txt --threads 4 &

# wait

bcftools index /workdir/yc2644/CV_LM_WGS/vcf_ALL_GATK/invariant_ALL_F_g0.25.vcf.gz --threads 4 &
#bcftools index /workdir/yc2644/CV_LM_WGS/vcf_ALL_GATK/snp_ALL_F_g0.75maf0.01.vcf.gz --threads 4 &
bcftools index /workdir/yc2644/CV_LM_WGS/vcf_ALL_GATK/snp_ALL_F_g0.25maf0.01.vcf.gz --threads 4 &
#bcftools index /workdir/yc2644/CV_LM_WGS/vcf_ALL_GATK/snp_ALL_F.vcf.gz --threads 4 &

# Concatenate invariant and SNP VCFs
cd /workdir/yc2644/CV_LM_WGS/vcf_ALL_GATK

bcftools concat --allow-overlaps -Oz -o all_sites_ALL_F.vcf.gz \
    invariant_ALL_F_g0.25.vcf.gz \
    snp_ALL_F_g0.25maf0.01.vcf.gz --threads 4 &
bcftools reheader --samples sample_id_n126_mod.txt -o all_sites_ALL_F.mod.vcf.gz all_sites_ALL_F.vcf.gz &
bcftools index all_sites_ALL_F.mod.vcf.gz --threads 4 &
