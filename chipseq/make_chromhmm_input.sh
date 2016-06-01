#!/bin/bash

DIR=/data/SBW2016/reference
WFILE=$DIR/mm10.200bp_windows.bed
CHROMSIZES=$DIR/mm10.chrom.sizes

KK=`awk '{print $1}' $CHROMSIZES`

## first we shall prepare IL4 and untreated macrophage files
cd chromHMM/IL4_input
cp ../../macs/H3K27ac_UT_peaks.bed MPH_H3K27ac.bed
cp ../../macs/H3K4me1_UT_peaks.bed MPH_H3K4me1.bed
cp ../../macs/H3K4me3_UT_peaks.bed MPH_H3K4me3.bed
cp ../../macs/H3K27ac_IL4_4h_peaks.bed MPH_H3K27ac_IL4.bed
cp ../../macs/H3K4me1_IL4_4h_peaks.bed MPH_H3K4me1_IL4.bed
cp ../../macs/H3K4me3_IL4_4h_peaks.bed MPH_H3K4me3_IL4.bed

for i in MPH*.bed
do 
  bedtools intersect -c -f 0.5 -b $i -a $WFILE > ${i%%.bed}_binary.bed & 
done
wait

for i in MPH*_binary.bed
do
  for j in $KK 
  do
    grep -P "$j\t" $i | awk '{print $4}' > ${i%%_binary.bed}_${j}.x & 
  done
  wait
  echo "IL4 chromHMM input: Done processing binary file $i"
done

ls MPH*_chr1.x | sed "s/_chr1\.x//g" |  sed "s/MPH_//g"> MPH.$$.marks 

PP=`cat MPH.$$.marks`

for j in $KK 
do
  echo "MPH $j" | sed "s/ /\t/g" > MPH_${j}_binary.txt
  echo $PP | sed "s/ /\t/g" >>  MPH_${j}_binary.txt
  paste MPH*_${j}.x >> MPH_${j}_binary.txt
done

rm *.x *binary.bed MPH.$$.marks

 
## now the same for untreated + LPS 
cd ../LPS_input
cp ../../macs/H3K27ac_UT_peaks.bed MPH_H3K27ac.bed
cp ../../macs/H3K4me1_UT_peaks.bed MPH_H3K4me1.bed
cp ../../macs/H3K4me3_UT_peaks.bed MPH_H3K4me3.bed
cp ../../macs/H3K27ac_LPS_4h_peaks.bed MPH_H3K27ac_LPS.bed
cp ../../macs/H3K4me1_LPS_4h_peaks.bed MPH_H3K4me1_LPS.bed
cp ../../macs/H3K4me3_LPS_4h_peaks.bed MPH_H3K4me3_LPS.bed

for i in MPH*.bed
do 
  bedtools intersect -c -f 0.5 -b $i -a $WFILE > ${i%%.bed}_binary.bed & 
done
wait

for i in MPH*_binary.bed
do
  for j in $KK 
  do
    grep -P "$j\t" $i | awk '{print $4}' > ${i%%_binary.bed}_${j}.x & 
  done
  wait
  echo "LPS chromHMM input: Done processing binary file $i"
done

ls MPH*_chr1.x | sed "s/_chr1\.x//g" |  sed "s/MPH_//g"> MPH.$$.marks 

PP=`cat MPH.$$.marks`

for j in $KK 
do
  echo "MPH $j" | sed "s/ /\t/g" > MPH_${j}_binary.txt
  echo $PP | sed "s/ /\t/g" >>  MPH_${j}_binary.txt
  paste MPH*_${j}.x >> MPH_${j}_binary.txt
done

rm *.x *binary.bed MPH.$$.marks
