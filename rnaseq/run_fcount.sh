#!/bin/bash

REFDIR=/mnt
GTF=$REFDIR/genprime_vM7/genprime_vM7.gtf
## simple 3-column file - ensemble GENE ID, gene symbol, and gene type. 
ANN=$REFDIR/genprime_vM7/genprime_vM7.3col.ann

cd bams 
BDIR=`pwd`
## variable KK now has all the sample names without extensions 
KK=`for i in *bam
do
  echo ${i%%.bam}
done`

cd ../featureCounts

for i in $KK 
do
  echo "featureCounts: quantifying expression for sample $i"
  ## -s no option is set to 0 because we have a non-strand-specific library
  featureCounts -a $GTF -s 0 -o $i.fcount.out $BDIR/$i.bam &> $i.fcount.log & 
done

wait

echo "featureCounts: generating a final expression table..."
for i in *.fcount.out 
do
  TAG=${i%%.fcount.out}
  echo $TAG > $TAG.tmp
  ## the following is necessary because HTSeq output has some technical info in the end of each file 
  awk '{if (NR>2) print $1,$7}' $i | sort -k1,1 | awk '{print $2}' >> $TAG.tmp
done

## this is to make the final table of per-GENE expression 
paste $ANN *.tmp > MPH.all_gene.fcount.counts
rm *.tmp
mkdir logs 
mv *log *summary logs 

cp MPH.all_gene.fcount.counts ../download

echo "ALL FEATURECOUNTS CALCULATIONS ARE DONE!"
echo
echo
