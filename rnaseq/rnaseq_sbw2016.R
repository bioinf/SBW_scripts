stringsAsFactors=F
setwd("~/rnaseq")
library(DESeq2)
library(ggplot2)
library(ggrepel)
library(reshape)

## let's read in the data and see some stats

tt1 <- read.table("MPH.all_gene.fcount.counts",header=T,row.names=1)
tt2 <- read.table("MPH.all_gene.kallisto.counts",header=T,row.names=1)
cond <- read.table("Conditions.txt",row.names=1,header=T)
head(tt1)
head(tt2)
cond
colSums(tt1[,c(3:15)])
colSums(tt2[,c(3:15)])

ann <- tt1[,c(1:2)]
ttf1 <- tt1[,!names(tt2) %in% c("Gene_symbol", "Gene_type")]
ttf2 <- tt2[,!names(tt2) %in% c("Gene_symbol", "Gene_type")]
## let's normalize the expression matrices to same library depth
ttn1 <- sweep(ttf1, 2, colSums(ttf1)/mean(colSums(ttf1)), FUN="/")
ttn2 <- sweep(ttf2, 2, colSums(ttf2)/mean(colSums(ttf2)), FUN="/")
colSums(ttn1)
colSums(ttn2)
dim(ttn1)
dim(ttn2)
## for PCA, let us only keep the genes with more than 50 reads on average
exp1 <- ttn1[apply(ttn1, 1, mean) > 50,]
exp2 <- ttn2[apply(ttn2, 1, mean) > 50,]
dim(exp1)
dim(exp2)
## log2 transform is pretty common when working with expression data 
expl1 <- log2(exp1+1)
expl2 <- log2(exp2+1)
boxplot(expl1)
boxplot(expl2)

## actual PCA calculation 

pca1 <- prcomp(t(expl1))
pca2 <- prcomp(t(expl2))
## only select first two components, PC1 and PC2 
pcat1 <- as.data.frame(pca1$x[, 1:2])
pcat2 <- as.data.frame(pca2$x[, 1:2])
## annotate each row with condition
pcat1$Condition <- as.character(sapply(rownames(pcat1), function(elt) cond[elt,1]))
pcat2$Condition <- as.character(sapply(rownames(pcat2), function(elt) cond[elt,1]))
pcat1
pcat2
#make pretty pictures 
ggplot(pcat1,aes(PC1,PC2)) + geom_point(aes(color=Condition)) + geom_text_repel(data=pcat1,aes(label=rownames(pcat1)))
ggplot(pcat2,aes(PC1,PC2)) + geom_point(aes(color=Condition)) + geom_text_repel(data=pcat2,aes(label=rownames(pcat2)))

summary(pca1)
summary(pca2)

## let's look at how kallisto and featureCounts relate to each other

a <- log2(tt1$MPH_IL4_rep1+1)
b <- log2(tt2$MPH_IL4_rep1+1)
plot(a,b,xlab="featureCounts",ylab="kallisto")
abline(0,1)

## now let's do differential expression with DESeq2
## we will use kallisto data (tt2)
## let's make separate files for each condtion

cond1 <- cond[cond$Condition %in% c("untreated","IL4"),,drop=F]
cond2 <- cond[cond$Condition %in% c("untreated","LPS_6h"),,drop=F]
expf1 <- tt2[,colnames(tt2) %in% rownames(cond1)]
expf2 <- tt2[,colnames(tt2) %in% rownames(cond2)]
## you also have to reorder the values, or DESeq2 complains (which is good)
expf1 <- expf1[,rownames(cond1)]
expf2 <- expf2[,rownames(cond2)]
cond1
head(expf1)
cond2
head(expf2)

## now let's set up actual DESeq2 class object
dds1 <- DESeqDataSetFromMatrix(countData=expf1,colData=cond1,design = ~ Condition)
dds2 <- DESeqDataSetFromMatrix(countData=expf2,colData=cond2,design = ~ Condition)
## and do differential expression analysis
ddsM1 <- DESeq(dds1)
ddsM2 <- DESeq(dds2)

res1 <- results(ddsM1)
res2 <- results(ddsM2)
resO1 <- as.data.frame(res1[order(res1$padj),])
resO2 <- as.data.frame(res2[order(res2$padj),])
head(resO1)
head(resO2)

## this is to filter, sort, and annotate the data
det1a <- merge(resO1,ann,by="row.names",all.x=TRUE)
dim(det1a)
det1b <- det1a[complete.cases(det1a),]
dim(det1b)
det1c <- det1b[,c("Row.names","Gene_symbol","Gene_type","baseMean","log2FoldChange","lfcSE","stat","pvalue","padj")]
det1d <- det1c[det1c$baseMean > 100 & det1c$padj < 0.05 & abs(det1c$log2FoldChange) > 1,]
dim(det1d)
det1e <- det1d[order(det1d$log2FoldChange),]

det2a <- merge(resO2,ann,by="row.names",all.x=TRUE)
dim(det2a)
det2b <- det2a[complete.cases(det2a),]
dim(det2b)
det2c <- det2b[,c("Row.names","Gene_symbol","Gene_type","baseMean","log2FoldChange","lfcSE","stat","pvalue","padj")]
det2d <- det2c[det2c$baseMean > 100 & det2c$padj < 0.05 & abs(det2c$log2FoldChange) > 1,]
dim(det2d)
det2e <- det2d[order(det2d$log2FoldChange),]

## finally, let's write some tables 
write.table(det1c,file="IL4_vs_untreated.full_deseq2.tsv",quote=F,sep="\t",row.names=F)
write.table(det2c,file="LPS_6h_vs_untreated.full_deseq2.tsv",quote=F,sep="\t",row.names=F)
write.table(det1e,file="IL4_vs_untreated.filtered_deseq2.tsv",quote=F,sep="\t",row.names=F)
write.table(det2e,file="LPS_6h_vs_untreated.filtered_deseq2.tsv",quote=F,sep="\t",row.names=F)

## let's check some canonical murine M1 markers:

det1a[det1a$Gene_symbol=="Arg1",]
det1a[det1a$Gene_symbol=="Chil3",]
det1a[det1a$Gene_symbol=="Chil4",]
det1a[det1a$Gene_symbol=="Retnla",]
det1a[det1a$Gene_symbol=="Tgm2",]
det1a[det1a$Gene_symbol=="Mrc1",]

## let's now check some murine M2 markers: 

det2a[det2a$Gene_symbol=="Nos2",]
det2a[det2a$Gene_symbol=="Il12b",]
det2a[det2a$Gene_symbol=="Il12a",]
det2a[det2a$Gene_symbol=="Tnf",]
det2a[det2a$Gene_symbol=="Cxcl9",]
det2a[det2a$Gene_symbol=="Cxcl10",]
det2a[det2a$Gene_symbol=="Cxcl11",]

