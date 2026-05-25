#!/bin/bash

REF=/workdir/yc2644/CV_LM_WGS/bam_ALL_GATK/CV30_masked_nomtDNA.fasta
#INPUT_BAM=/workdir/yc2644/CV_LM_WGS/bam_ALL_GATK/ALL_bamlist
INPUT_BAM=/workdir/yc2644/CV_LM_WGS/bam_ALL_GATK/ALL_down_bamlist
CONTIGS=/workdir/yc2644/CV_LM_WGS/bam_ALL_GATK/chr.list

cd ./vcfs

# collect INFO/DP from all contig VCFs into one file
for contig in $(cat $CONTIGS); do
    bcftools query -f '%INFO/DP\n' allsites_ALL_${contig}.vcf.gz
done > allsites_ALL_siteDP.txt &

for contig in $(cat $CONTIGS); do
    bcftools query -f '%INFO/DP\n' snp_ALL_${contig}.vcf.gz
done > snp_ALL_siteDP.txt &

for contig in $(cat $CONTIGS); do
    bcftools query -f '%INFO/DP\n' invariant_ALL_${contig}.vcf.gz
done > invariant_ALL_siteDP.txt &

awk '
   /^[0-9]+$/ {        # only keep numeric lines
     n++
     sum += $1
     sumsq += ($1)^2
   }
   END {
     mean = sum/n
     sd = sqrt(sumsq/n - mean^2)
     print "Sites:", n
     print "Mean:", mean
     print "SD:", sd
     for (k=1; k<=3; k++) {
       printf "Mean-%d*SD: %.2f, Mean+%d*SD: %.2f\n", k, mean-k*sd, k, mean+k*sd
     }
   }
 ' snp_ALL_siteDP.txt
# no down
# Sites: 572544650
# Mean: 1687.3
# SD: 1466.68
# Mean-1*SD: 220.62, Mean+1*SD: 3153.98
# Mean-2*SD: -1246.06, Mean+2*SD: 4620.66
# Mean-3*SD: -2712.75, Mean+3*SD: 6087.34
# after down
# Sites: 572428597
# Mean: 1634.89
# SD: 1420.32
# Mean-1*SD: 214.58, Mean+1*SD: 3055.21
# Mean-2*SD: -1205.74, Mean+2*SD: 4475.53
# Mean-3*SD: -2626.06, Mean+3*SD: 5895.84

python3 - <<'PY'
import matplotlib.pyplot as plt

# Parameters
bin_size = 100           # DP bin width
max_dp = 8000           # max DP to display (adjust if needed)
bins = list(range(0, max_dp + bin_size, bin_size))
counts = [0] * len(bins)

# Stream file line by line
#with open("allsites_ALL_siteDP.txt") as f:
with open("snp_ALL_siteDP.txt") as f:
    for line in f:
        line = line.strip()
        if not line or line == '.':
            continue
        dp = int(line)
        if dp > max_dp:
            dp = max_dp
        bin_idx = dp // bin_size
        counts[bin_idx] += 1

# Plot
plt.figure(figsize=(10,6))
plt.bar(bins, counts, width=bin_size, color='steelblue', edgecolor='black', align='edge')
plt.xlabel("Site depth (DP)")
plt.ylabel("Number of sites")
plt.title("Site-level DP histogram (binned)")
#plt.yscale("log")   # optional log scale to see tail

# mean=1634.89
# mean_minus_sd=214.58
# mean_plus_sd=3055.21
# mean_plus_2sd=4475.53

# # Add mean and ±SD lines
# plt.axvline(mean, color="red", linestyle="--", linewidth=1.5, label=f"Mean = {mean:.1f}")
# plt.axvline(mean_minus_sd, color="green", linestyle="--", linewidth=1.5, label=f"Mean - SD = {mean_minus_sd:.1f}")
# plt.axvline(mean_plus_sd, color="green", linestyle="--", linewidth=1.5, label=f"Mean + SD = {mean_plus_sd:.1f}")
# plt.axvline(mean_plus_2sd, color="green", linestyle="--", linewidth=1.5, label=f"Mean + 2SD = {mean_plus_2sd:.1f}")

plt.tight_layout()
plt.savefig("depth_hist_binned_snp.png", dpi=200)
PY
