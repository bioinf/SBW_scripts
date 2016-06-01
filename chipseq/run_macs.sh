#!/bin/bash 

cd bams 
BDIR=`pwd`

KK=`for i in *bam
do
  echo ${i%%.bam}
done`

cd ../macs

for i in $KK
do 
  echo "macs14: Calling peaks for sample $i" 
  ## macs v. 1.4 is the most established peak caller for narrow Chip-Seq peaks 
  macs14 -t $BDIR/$i.bam -f BAM -g mm -n $i --verbose=2  &> $i.macs.log & 
done 

wait 

mkdir logs
mv *log logs 
## again, this is for the convenience of the download
cp *peaks.bed ../download

echo "ALL PEAK CALLING IS DONE!"
echo
echo
