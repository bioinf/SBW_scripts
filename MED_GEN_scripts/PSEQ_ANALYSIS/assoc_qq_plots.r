d.table("var_assoc.txt",header=T,sep="\t")
 pvals<-tt$P
 observed <- sort(pvals)
 lobs <- -(log10(observed))
  
  expected <- c(1:length(observed)) 
  lexp <- -(log10(expected / (length(expected)+1)))

pdf("variants_asssoc_qq.pdf") 
  plot(c(0,7), c(0,7), col="red", lwd=3, type="l", xlab="Expected (-logP)", ylab="Observed (-logP)", xlim=c(0,7), ylim=c(0,7), las=1, xaxs="i", yaxs="i", bty="l")

  points(lexp, lobs, pch=23, cex=.4, bg="black")
dev.off()

tt<-read.table("gene_assoc.test",header=T,sep="\t")
tmp<-cbind(as.character(unlist(tt[which(tt$TEST=="BURDEN"),1])),as.character(unlist(tt[which(tt$TEST=="BURDEN"),2])),tt[which(tt$TEST=="BURDEN"),6],tt[which(tt$TEST=="VT"),6],tt[which(tt$TEST=="CALPHA"),6],as.character(unlist(tt[which(tt$TEST=="BURDEN"),8])))

colnames(tmp)<-c("LOCUS","POS","BURDEN_P","VT_P","CALPHA_P","CASE_CONTROL_ALT_ALLELES")

write.table(tmp,"gene_assoc_summary.txt",row.names=F,sep="\t",quote=F)

pvals<-tmp$BURDEN_P
observed <- sort(pvals)
 lobs <- -(log10(observed))
  
  expected <- c(1:length(observed)) 
  lexp <- -(log10(expected / (length(expected)+1)))

pdf("gene_assoc_burden_qq.pdf") 
  plot(c(0,7), c(0,7), col="red", lwd=3, type="l", xlab="Expected (-logP)", ylab="Observed (-logP)", xlim=c(0,7), ylim=c(0,7), las=1, xaxs="i", yaxs="i", bty="l")

  points(lexp, lobs, pch=23, cex=.4, bg="black")
dev.off()

pvals<-tmp$VT_P
observed <- sort(pvals)
 lobs <- -(log10(observed))
  
  expected <- c(1:length(observed)) 
  lexp <- -(log10(expected / (length(expected)+1)))

pdf("gene_assoc_vt_qq.pdf") 
  plot(c(0,7), c(0,7), col="red", lwd=3, type="l", xlab="Expected (-logP)", ylab="Observed (-logP)", xlim=c(0,7), ylim=c(0,7), las=1, xaxs="i", yaxs="i", bty="l")

  points(lexp, lobs, pch=23, cex=.4, bg="black")
dev.off()

pvals<-tmp$CALPHA_P
observed <- sort(pvals)
 lobs <- -(log10(observed))
  
  expected <- c(1:length(observed)) 
  lexp <- -(log10(expected / (length(expected)+1)))

pdf("gene_assoc_calpha_qq.pdf") 
  plot(c(0,7), c(0,7), col="red", lwd=3, type="l", xlab="Expected (-logP)", ylab="Observed (-logP)", xlim=c(0,7), ylim=c(0,7), las=1, xaxs="i", yaxs="i", bty="l")

  points(lexp, lobs, pch=23, cex=.4, bg="black")
dev.off()


