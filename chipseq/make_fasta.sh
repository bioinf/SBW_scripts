#!/bin/bash 

REFDIR=/mnt
FA=$REFDIR/genprime_vM7/genprime_vM7.fa

cd chromHMM/IL4.16_state.output

grep -P "\tE8$" MPH_16_segments.bed > IL4.latent_enhancers.bed
grep -P "\tE5$" MPH_16_segments.bed > IL4.repressed_enhancers.bed
cp IL4.latent_enhancers.bed IL4.repressed_enhancers.bed ../../bed_and_fasta

cd ../LPS.16_state.output

grep -P "\tE6$" MPH_16_segments.bed > LPS.latent_enhancers.bed
grep -P "\tE9$" MPH_16_segments.bed > LPS.repressed_enhancers.bed
cp LPS.latent_enhancers.bed LPS.repressed_enhancers.bed ../../bed_and_fasta

cd ../../bed_and_fasta
cp ../macs/PU1_IL4_4h_peaks.bed .
cp ../macs/PU1_IL4_4h_summits.bed .
cp ../macs/PU1_LPS_4h_peaks.bed .
cp ../macs/PU1_LPS_4h_summits.bed .

bedtools intersect -wa -a PU1_IL4_4h_peaks.bed -b IL4.latent_enhancers.bed    | sort -k5,5nr | head -n 600 > PU1_IL4_latent.bed
bedtools intersect -wa -a PU1_IL4_4h_peaks.bed -b IL4.repressed_enhancers.bed | sort -k5,5nr | head -n 600 > PU1_IL4_repressed.bed

bedtools intersect -wa -a PU1_LPS_4h_peaks.bed -b LPS.latent_enhancers.bed    | sort -k5,5nr | head -n 600 > PU1_LPS_latent.bed
bedtools intersect -wa -a PU1_LPS_4h_peaks.bed -b LPS.repressed_enhancers.bed | sort -k5,5nr | head -n 600 > PU1_LPS_repressed.bed

for i in PU1_IL4_latent.bed PU1_IL4_repressed.bed
do
  TAG=${i%%.bed}
  KK=`awk   '{print $4}' $i`
  for j in $KK
  do 
    grep -P "\t$j\t" PU1_IL4_4h_summits.bed | awk '{printf "%s\t%d\t%d\t%s\n",$1,$2-50,$3+50,$4}' 
  done  | sort | uniq > $TAG.extracted.bed
  bedtools getfasta -fi $FA -bed $TAG.extracted.bed -fo $TAG.extracted.fa
done 

for i in PU1_LPS_latent.bed PU1_LPS_repressed.bed
do
  TAG=${i%%.bed}
  KK=`awk   '{print $4}' $i`
  for j in $KK
  do 
    grep -P "\t$j\t" PU1_LPS_4h_summits.bed | awk '{printf "%s\t%d\t%d\t%s\n",$1,$2-50,$3+50,$4}' 
  done  | sort | uniq > $TAG.extracted.bed
  bedtools getfasta -fi $FA -bed $TAG.extracted.bed -fo $TAG.extracted.fa
done
