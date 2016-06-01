#!/bin/bash 

## this is where FastQC is installed - it requires some extra files
PGDIR=/data/SBW2016/programs
cd fastqs

for i in *.fastq.gz
do
  echo "fastqc: Gathering sequencing metrics for sample $i"
  $PGDIR/FastQC/fastqc -q $i & 
done 
## this technique (running many jobs in background with & 
## and "waiting" for them to finish - allows for simple parallel execution
wait 

## zip archives contain same files as html, we don't need them
rm *zip
mv *html ../FastQC

## put in the same location for download
cp ../FastQC/*html ../download

echo "ALL FASTQC PROCESSING IS DONE!"
echo
echo
