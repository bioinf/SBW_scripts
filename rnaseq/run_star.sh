#!/bin/bash 

## this is where pre-generated STAR reference is located
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
  ## this command also will generate a transcriptomic BAM file which can be used for RSEM or other similar tools 
  STAR --genomeDir $REF --genomeLoad LoadAndKeep --readFilesIn $FQDIR/$i.fastq.gz --runThreadN 4 --readFilesCommand zcat \
  --outFilterMultimapNmax 15 --outFilterMismatchNmax 6  --outSAMstrandField All \
  --outSAMtype BAM Unsorted --quantMode TranscriptomeSAM &> $i.star_stdout.log 

  mv Aligned.out.bam ../bams/$i.bam
  mv Aligned.toTranscriptome.out.bam ../tr_bams/$i.tr.bam 
  mv Log.out $i.star_run.log 
  mv Log.final.out $i.star_final.log
done

## purge the genome from RAM and remove temporary files 
STAR --genomeDir $REF --genomeLoad Remove
rm -rf _STARtmp SJ.out.tab Aligned.out.sam Log.out Log.progress.out

echo "ALL ALIGNMENT IS DONE!"
echo
echo
