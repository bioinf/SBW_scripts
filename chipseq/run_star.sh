#!/bin/bash 

## this is where pre-generated STAR reference is located
##REF=/data/SBW2016/reference/STAR/genprime_vM7_101bp
REFDIR=/mnt
REF=$REFDIR/STAR/genprime_vM7_101bp

## variable KK will have a list of all file names without extensions
cd fastqs
FQDIR=`pwd`
KK=`for i in *fastq.gz
do 
  echo ${i%%.fastq.gz}
done`

cd ../STAR
for i in $KK
do
  echo "STAR: aligning sample $i" 
  ## LoadAndKeep option allows to save lots of time on genome loading
  ## extra options for purely genomic alignment: --alignIntronMax 1 --alignEndsType EndToEnd 
  STAR --genomeDir $REF --genomeLoad LoadAndKeep --readFilesIn $FQDIR/$i.fastq.gz --runThreadN 4 --readFilesCommand zcat \
  --outFilterMultimapNmax 15 --outFilterMismatchNmax 6  --outSAMstrandField All \
  --outSAMtype BAM Unsorted --alignIntronMax 1 --alignEndsType EndToEnd --seedSearchStartLmax 30 &> $i.star_stdout.log

  mv Aligned.out.bam ../bams/$i.bam
  mv Log.out $i.star_run.log
  mv Log.final.out $i.star_final.log
done

## purge the genome from RAM and remove temporary files 
STAR --genomeDir $REF --genomeLoad Remove
rm -rf _STARtmp SJ.out.tab Aligned.out.sam Log.out Log.progress.out

echo
for i in *star_final.log
do 
  TAG=${i%%.star_final.log}
  echo -e $TAG"\t\t"`grep "Uniquely mapped reads %" $i`
done
echo

echo "ALL ALIGNMENT IS DONE!"
echo
echo
