#where data is
#/data/SBW2016/Nikita/NIKITA/EXOME_SEQ/alignment/ALIGNMENT/

#0)Convertion of FastQ format to BAM. Command line will depend on the sequencing machine and format of the machine quality scores report

java -Xmx2G -jar /data/SBW2016/programs/1.403/bin/FastqToSam.jar FASTQ=/data/SBW2016/Nikita/NIKITA/EXOME_SEQ/alignment/ALIGNMENT/SRR000930_1.recal.fastq FASTQ2=/data/SBW2016/Nikita/NIKITA/EXOME_SEQ/alignment/ALIGNMENT/SRR000930_2.recal.fastq QUALITY_FORMAT=Solexa OUTPUT=NA11919.converted.bam READ_GROUP_NAME=rgname SAMPLE_NAME=1 SORT_ORDER=unsorted PLATFORM=ILLUMINA PLATFORM_UNIT=pu1 LIBRARY_NAME=lbname

#1) Revertion of BAM file - this is optional step, though not too time consuming. This allows to get the platform independent BAM file and start processing the data from the blank page, which ensures the proper alignment.

java -Dsamjdk.compression_level=1 -XX:GCTimeLimit=50 -XX:GCHeapFreeLimit=10 -Xmx4000m -jar /data/SBW2016/programs/1.403/bin/RevertSam.jar TMP_DIR=/data/SBW2016/tmp VALIDATION_STRINGENCY=SILENT INPUT=NA11919.converted.bam OUTPUT=NA11919.reverted.bam SORT_ORDER=queryname RESTORE_ORIGINAL_QUALITIES=true REMOVE_DUPLICATE_INFORMATION=true REMOVE_ALIGNMENT_INFORMATION=true ATTRIBUTE_TO_CLEAR=X0 ATTRIBUTE_TO_CLEAR=X1 ATTRIBUTE_TO_CLEAR=XA ATTRIBUTE_TO_CLEAR=XC ATTRIBUTE_TO_CLEAR=XG ATTRIBUTE_TO_CLEAR=XM ATTRIBUTE_TO_CLEAR=XN ATTRIBUTE_TO_CLEAR=XO ATTRIBUTE_TO_CLEAR=XT ATTRIBUTE_TO_CLEAR=AM ATTRIBUTE_TO_CLEAR=AS ATTRIBUTE_TO_CLEAR=BQ ATTRIBUTE_TO_CLEAR=CC ATTRIBUTE_TO_CLEAR=CP ATTRIBUTE_TO_CLEAR=E2 ATTRIBUTE_TO_CLEAR=H0 ATTRIBUTE_TO_CLEAR=H1 ATTRIBUTE_TO_CLEAR=H2 ATTRIBUTE_TO_CLEAR=HI ATTRIBUTE_TO_CLEAR=IH ATTRIBUTE_TO_CLEAR=MF ATTRIBUTE_TO_CLEAR=NH ATTRIBUTE_TO_CLEAR=OC ATTRIBUTE_TO_CLEAR=OP ATTRIBUTE_TO_CLEAR=PQ ATTRIBUTE_TO_CLEAR=R2 ATTRIBUTE_TO_CLEAR=S2 ATTRIBUTE_TO_CLEAR=SM ATTRIBUTE_TO_CLEAR=SQ ATTRIBUTE_TO_CLEAR=U2 ATTRIBUTE_TO_CLEAR=XQ

#2) Marks adapters from the actual sequence of the read 
java -Dsamjdk.compression_level=1 -XX:GCTimeLimit=50 -XX:GCHeapFreeLimit=10 -Xmx4000m -jar /data/SBW2016/programs/1.403/bin/MarkIlluminaAdapters.jar TMP_DIR=/data/SBW2016/tmp INPUT=NA11919.reverted.bam OUTPUT=NA11919.unmapped.bam M=NA11919.adapter_metrics PE=true ADAPTERS=PAIRED_END

#3) Getting FastQ files from reverted bam file
java -Dsamjdk.use_async_io=true -Dsamjdk.compression_level=1 -XX:GCTimeLimit=50 -XX:GCHeapFreeLimit=10 -Xmx1024m -jar /data/SBW2016/programs/1.403/bin/SamToFastq.jar TMP_DIR=/data/SBW2016/tmp INPUT=NA11919.unmapped.bam FASTQ=NA11919_1.tmp.fq SECOND_END_FASTQ=NA11919_3.tmp.fq NON_PF=true CLIPPING_ATTRIBUTE=XT CLIPPING_ACTION=2

#4) Alignment of FastQ files with BWA

/data/SBW2016/programs/bwa/bwa-0.7.3a/bwa aln /data/SBW2016/reference/REFDB_EXOME/Homo_sapiens_assembly19.fasta -q 5 -l 32 -k 2  -o 1 -f NA11919_3.tmp.sai NA11919_3.tmp.fq

/data/SBW2016/programs/bwa/bwa-0.7.3a/bwa aln /data/SBW2016/reference/REFDB_EXOME/Homo_sapiens_assembly19.fasta -q 5 -l 32 -k 2  -o 1 -f NA11919_1.tmp.sai NA11919_1.tmp.fq

/data/SBW2016/programs/bwa/bwa-0.7.3a/bwa sampe   -P -a 450 -f NA11919.Homo_sapiens_assembly19.aligned_bwa.sam /data/SBW2016/reference/REFDB_EXOME/Homo_sapiens_assembly19.fasta NA11919_1.tmp.sai NA11919_3.tmp.sai NA11919_1.tmp.fq NA11919_3.tmp.fq

#5) Merging alignments
java -Dsamjdk.compression_level=1 -Xmx2000m -jar /data/SBW2016/programs/1.403/bin/MergeBamAlignment.jar TMP_DIR=/data/SBW2016/tmp VALIDATION_STRINGENCY=SILENT CREATE_INDEX=true ALIGNED_BAM=NA11919.Homo_sapiens_assembly19.aligned_bwa.sam EXPECTED_ORIENTATIONS=FR UNMAPPED_BAM=NA11919.unmapped.bam OUTPUT=NA11919.aligned.bam REFERENCE_SEQUENCE=/data/SBW2016/reference/REFDB_EXOME/Homo_sapiens_assembly19.fasta PAIRED_RUN=true IS_BISULFITE_SEQUENCE=false ALIGNED_READS_ONLY=false CLIP_ADAPTERS=false MAX_RECORDS_IN_RAM=2000000 PROGRAM_RECORD_ID=bwa PROGRAM_GROUP_VERSION=0.5.9-tpx PROGRAM_GROUP_COMMAND_LINE=bwa 

#6) Mark Duplicates

java -Dsamjdk.compression_level=1 -XX:GCTimeLimit=50 -XX:GCHeapFreeLimit=10 -Xmx4000m -jar /data/SBW2016/programs/1.403/bin/MarkDuplicates.jar TMP_DIR=/data/SBW2016/tmp CREATE_INDEX=true CREATE_MD5_FILE=true INPUT=NA11919.aligned.bam OUTPUT=NA11919.aligned.duplicates_marked.bam METRICS_FILE=NA11919.duplicate_metrics VALIDATION_STRINGENCY=SILENT

#7) Realign indels

java -Djava.io.tmpdir=/data/SBW2016/tmp -Dsamjdk.use_async_io=true -XX:GCTimeLimit=50 -XX:GCHeapFreeLimit=10 -Xmx4000m -jar /data/SBW2016/programs/GenomeAnalysisTK-3.1-144-g00f68a3.jar -T IndelRealigner -U -R /data/SBW2016/reference/REFDB_EXOME/Homo_sapiens_assembly19.fasta -o NA11919.aligned.duplicates_marked.indel_cleaned.bam -I NA11919.aligned.duplicates_marked.bam  -compress 1 -targetIntervals /data/SBW2016/reference/REFDB_EXOME/Homo_sapiens_assembly19.indel_cleaner.intervals -model KNOWNS_ONLY -maxInMemory 1000000 -known /data/SBW2016/reference/REFDB_EXOME/Homo_sapiens_assembly19.dbsnp.vcf -LOD 0.4 -known /data/SBW2016/reference/REFDB_EXOME/Homo_sapiens_assembly19.1kg_pilot_indels.vcf

#8) Recalibrate scores

java -XX:GCTimeLimit=50 -XX:GCHeapFreeLimit=10 -Xmx4000m -jar /data/SBW2016/programs/GenomeAnalysisTK-3.1-144-g00f68a3.jar -T BaseRecalibrator -R /data/SBW2016/reference/REFDB_EXOME/Homo_sapiens_assembly19.fasta -I NA11919.aligned.duplicates_marked.indel_cleaned.bam   -cov ReadGroupCovariate -cov QualityScoreCovariate -cov CycleCovariate -maxCycle 600 -cov ContextCovariate -o NA11919.recal_data.csv -l INFO -OQ --knownSites /data/SBW2016/reference/REFDB_EXOME/Homo_sapiens_assembly19.dbsnp.vcf

#9) Score Recalibration filtering


java -Dsamjdk.use_async_io=true -XX:GCTimeLimit=50 -XX:GCHeapFreeLimit=10 -Xmx4000m -jar /data/SBW2016/programs/GenomeAnalysisTK-3.1-144-g00f68a3.jar -T PrintReads --generate_md5 -U -BQSR NA11919.recal_data.csv -R /data/SBW2016/reference/REFDB_EXOME/Homo_sapiens_assembly19.fasta -o NA11919.final.bam -I NA11919.aligned.duplicates_marked.indel_cleaned.bam  



