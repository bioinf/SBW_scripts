#!/bin/bash 

## kallisto index has to be pre-made separately
REFDIR=/mnt
REF=$REFDIR/kallisto/genprime_vM7_kallisto
## same as with HTSeq, this is mouse Gencode vM7 annotation, of primary assembly for GRCm38.p4
GTF=$REFDIR/genprime_vM7/genprime_vM7.gtf
ANN=$REFDIR/genprime_vM7/genprime_vM7.3col.ann

cd fastqs 
FQDIR=`pwd`

KK=`for i in *fastq.gz
do
  echo ${i%%.fastq.gz}
done`

cd ../kallisto
for i in $KK
do
  echo "kallisto: quantifying expression for sample $i"
  ## kallisto is build with paired ends in mind, so "--single -l 200 -s 50" options are necessary for single-end reads. 
  kallisto quant -i $REF -t 4 --single -l 200 -s 50 --plaintext -o ${i}_kallisto $FQDIR/$i.fastq.gz &> $i.kallisto.log  
  mv ${i}_kallisto/abundance.tsv ${i}.tsv
done

mkdir logs
mv *log logs 

## the folders only contain technical info, let's remove them
rm -rf *_kallisto

## this script simply sums per-transcript read counts and TPMs into per-gene counts and TPMs 
python ../kallisto_per_gene_counts.py -a $GTF *tsv

echo "kallisto: generating the expression table file"

for i in *_per_gene.tsv
do
  echo "processing file $i" 
  TAG=${i%%_per_gene.tsv}
  echo $TAG > $TAG.tmp
  ## floating point number rounding makes it compatible with integer count-based tools such as DESeq2
  awk '{if (NR>1) print}' $i | sort -k1,1 | awk '{printf "%.0f\n",$2}'   >> $TAG.tmp
done

## final per-GENE expression table 
paste $ANN *.tmp > MPH.all_gene.kallisto.counts
rm *.tmp

cp MPH.all_gene.kallisto.counts ../download

echo "ALL KALLISTO CALCULATIONS ARE DONE!"
echo
echo
