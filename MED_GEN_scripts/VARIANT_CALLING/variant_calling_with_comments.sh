#1) Running unified genotyper. This will produce initial callset with no quality filters applied

java -Xmx4000m -jar -Djava.io.tmpdir=/data/SBW2016/tmp /data/SBW2016/programs/GenomeAnalysisTK-3.1-144-g00f68a3.jar  -T UnifiedGenotyper -I /data/SBW2016/Nikita/NIKITA/EXOME_SEQ/VARIANT_CALLING/bam.list -L /data/SBW2016/Nikita/NIKITA/EXOME_SEQ/VARIANT_CALLING/calling_intervals.interval_list  -R /data/SBW2016/reference/REFDB_EXOME/Homo_sapiens_assembly19.fasta  -dcov 600  -glm BOTH  -D /data/SBW2016/reference/REFDB_EXOME/Homo_sapiens_assembly19.dbsnp.vcf  -o unfiltered.vcf

#2) Select only SNPs
java -Xmx4000m -Djava.io.tmpdir=/data/SBW2016/tmp -jar /data/SBW2016/programs/GenomeAnalysisTK-3.1-144-g00f68a3.jar  -T SelectVariants  -L /data/SBW2016/Nikita/NIKITA/EXOME_SEQ/VARIANT_CALLING/calling_intervals.interval_list  -R /data/SBW2016/reference/REFDB_EXOME/Homo_sapiens_assembly19.fasta  -V unfiltered.vcf  -o snps.unfiltered.vcf -selectType SNP

#3) Select only INDELs

java -Xmx4000m -Djava.io.tmpdir=/data/SBW2016/tmp -jar /data/SBW2016/programs/GenomeAnalysisTK-3.1-144-g00f68a3.jar  -T SelectVariants  -L /data/SBW2016/Nikita/NIKITA/EXOME_SEQ/VARIANT_CALLING/calling_intervals.interval_list  -R /data/SBW2016/reference/REFDB_EXOME/Homo_sapiens_assembly19.fasta  -V unfiltered.vcf  -o indels.unfiltered.vcf -selectType INDEL

#4) Filter SNPs
java -Xmx4000m -Djava.io.tmpdir=/data/SBW2016/tmp -jar  /data/SBW2016/programs/GenomeAnalysisTK-3.1-144-g00f68a3.jar  -T VariantFiltration  -L /data/SBW2016/Nikita/NIKITA/EXOME_SEQ/VARIANT_CALLING/calling_intervals.interval_list  -R /data/SBW2016/reference/REFDB_EXOME/Homo_sapiens_assembly19.fasta  -V snps.unfiltered.vcf  -o snps.filtered.vcf  -filter "QD<2.0" -filter "MQ<40.0" -filter "HaplotypeScore>13.0" -filter "MQRankSum<-12.5" -filter "ReadPosRankSum<-8.0" -filter "FS>60.0"  -filterName SNP_QD -filterName SNP_MQ -filterName SNP_HaplotypeScore -filterName SNP_MQRankSum -filterName SNP_ReadPosRankSum -filterName SNP_FS

#5) Filter INDELs
java  -Xmx4000m  -Djava.io.tmpdir=/data/SBW2016/tmp  -jar /data/SBW2016/programs/GenomeAnalysisTK-3.1-144-g00f68a3.jar  -T VariantFiltration  -L /data/SBW2016/Nikita/NIKITA/EXOME_SEQ/VARIANT_CALLING/calling_intervals.interval_list -R /data/SBW2016/reference/REFDB_EXOME/Homo_sapiens_assembly19.fasta  -V indels.unfiltered.vcf  -o indels.filtered.vcf  -filter "FS>200.0" -filter "QD<2.0" -filter "ReadPosRankSum<-20.0" -filter "InbreedingCoeff<-0.8"  -filterName Indel_FS -filterName Indel_QD -filterName Indel_ReadPosRankSum -filterName Indel_InbreedingCoeff

#6) Combine SNPs and INDELs
java  -Xmx4000m  -Djava.io.tmpdir=/data/SBW2016/tmp  -jar /data/SBW2016/programs/GenomeAnalysisTK-3.1-144-g00f68a3.jar  -T CombineVariants  -L /data/SBW2016/Nikita/NIKITA/EXOME_SEQ/VARIANT_CALLING/calling_intervals.interval_list -R /data/SBW2016/reference/REFDB_EXOME/Homo_sapiens_assembly19.fasta  -V:indels indels.filtered.vcf -V:snps snps.filtered.vcf  -o unannotated.vcf  -filteredRecordsMergeType KEEP_IF_ANY_UNFILTERED  -assumeIdenticalSamples

#7) Create SNPEff annotation
java -Xmx4000m -jar /data/SBW2016/programs/snpEff_2_0_5/snpEff.jar eff -o vcf -v hg19 unannotated.vcf -c /data/SBW2016/programs/snpEff_2_0_5/snpEff.config > unannotated.snpeff.vcf

#8) output table of annotations
/data/SBW2016/programs/vcftools_0.1.8a/bin/vcftools --vcf final.vcf --get-INFO SNPEFF_GENE_NAME --get-INFO SNPEFF_EFFECT

#8) Parse annotation into VCF file
java  -Xmx4000m  -Djava.io.tmpdir=/data/SBW2016/tmp  -jar /data/SBW2016/programs/GenomeAnalysisTK-3.1-144-g00f68a3.jar  -T VariantAnnotator  -L /data/SBW2016/Nikita/NIKITA/EXOME_SEQ/VARIANT_CALLING/calling_intervals.interval_list   -R /data/SBW2016/reference/REFDB_EXOME/Homo_sapiens_assembly19.fasta  -V unannotated.vcf  -snpEffFile unannotated.snpeff.vcf  -o final.vcf  -A SnpEff

