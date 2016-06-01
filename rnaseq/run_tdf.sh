#!/bin/bash

## this is where IGVtools is installed. 
PGDIR=/data/SBW2016/programs
cd bams 
BDIR=`pwd`

KK=`for i in *bam
do
  echo ${i%%.bam}
done`

cd ../tdfs

for i in $KK
do 
  echo "igvtools: Making tdf files for sample $i" 
  ## you can add other .genome files to appropriate directory of IGVtools 
  ## right now we are using mm10 and thus are losing all the reads on scaffolds etc in the resulting TDF file 
  $PGDIR/IGVTools/igvtools count -z 5 -w 50 -e 0 $BDIR/$i.bam $i.tdf mm10 >& $i.tdf.log & 
done 

wait 

mkdir logs
mv *log logs 
## again, this is for the convenience of the download
cp *tdf ../download

echo "ALL TDF PREPARAION IS DONE!"
echo
echo


