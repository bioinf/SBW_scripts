#!/bin/bash

cd bams 

for i in *bam
do
  TAG=${i%%.bam}
  echo "samtools: sorting and indexing sample $i"
  ## sorting
  samtools sort -@ 4 -T $TAG -o $TAG.sorted.bam $TAG.bam
  mv $TAG.sorted.bam $TAG.bam
  ## indexing the BAM file
  samtools index $i 
done

echo "ALL SORTING AND INDEXING IS DONE!"
echo
echo
