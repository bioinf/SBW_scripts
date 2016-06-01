#!/bin/bash

SPECIES=mm10

DIR=`pwd`
cd tdfs

for i in $DIR/bams/*bam
do
  BAM=${i##*/}
  TAG=${BAM%%.bam}
  igvtools count -z 5 -w 50 -e 0 $i $TAG.tdf $SPECIES >& $TAG.make_tdf.log & 
done

wait

mkdir logs 
mv *log logs 
