#2) Create pseq project
/data/SBW2016/programs/plink-seq/plinkseq-0.08-x86_64/pseq test_pseq new-project --resources /data/SBW2016/programs/plink-seq/db/hg18

#3) Load VCF files. With large data you can use index-vcf for saving disk space
/data/SBW2016/programs/plink-seq/plinkseq-0.08-x86_64/pseq test_pseq load-vcf --vcf /data/SBW2016/Nikita/NIKITA/EXOME_SEQ/PSEQ/*.vcf

#4) Load phenotype
/data/SBW2016/programs/plink-seq/plinkseq-0.08-x86_64/pseq test_pseq load-pheno --file /data/SBW2016/Nikita/NIKITA/EXOME_SEQ/PSEQ/pop_struct.phe

#5) Run common variants analysis:
/data/SBW2016/programs/plink-seq/plinkseq-0.08-x86_64/pseq test_pseq v-assoc --perm -1 --phenotype phe1 --mask maf=0.05- geno.req=DP:ge:10 any.filter.ex null=0-10 > common_assoc.txt

#6) Create qq-plot for common variants. If cases and controls are well-matched - it should be null
Rscript qq_plot_common_var.r

#7) Run i-stats
/data/SBW2016/programs/plink-seq/plinkseq-0.08-x86_64/pseq test_pseq i-stats --mask  geno.req=DP:ge:10 any.filter.ex null=0-10 > istats.txt

#8) Make histogram and identify outliers
Rscript qc_cleaning.r

#9) Run variant associations
/data/SBW2016/programs/plink-seq/plinkseq-0.08-x86_64/pseq test_pseq v-assoc --perm -1 --phenotype phe1 --mask indiv.ex=@rm_indiv.txt geno.req=DP:ge:10 any.filter.ex null=0-10 > var_assoc.txt

#10) Run gene associations
/data/SBW2016/programs/plink-seq/plinkseq-0.08-x86_64/pseq test_pseq assoc --tests calpha vt --phenotype phe1 --mask indiv.ex=@rm_indiv.txt mac=1-10 geno.req=DP:ge:10 any.filter.ex null=0-10 loc.group=refseq > gene_assoc.test

#11) Assemble gene associations and create qq-plots
Rscript assoc_qq_plots.r

