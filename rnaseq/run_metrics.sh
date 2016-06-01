#!/bin/bash 

BAMDIR=/data/SBW2016/RNA_Seq/bams
LOGDIR=/data/SBW2016/RNA_Seq/STAR

cd bams 
KK=`for i in *bam
do 
  echo ${i%%.bam}
done`

cd ../stats
for i in $KK
do
  echo "RNA-seq metrics: processing sample $i"
  ## this is a sample script that calculates rRNA percentage, alignment stats, and annotation-specific detail of alignment 
  ../star_stat.sh $BAMDIR $LOGDIR $i &> $i.metrics.log & 
done

wait
mkdir logs 
mv *log logs 
echo
echo

echo "Your experiments have the following strandedness:"
strand
echo
echo

echo -e "Sample\treads\t%_mapped\t%_uniq\t%_unmap\t%_rRNA\t%_coding\t%_UTR\t%_intron\t%_inter\tJunc\tIns_rate\tDel_rate\t%_NC_junc\tDel_AL\tIns_AL"
cat *rnastat
echo

echo "ALL METRICS CALCULATIONS ARE DONE!"
echo
echo
