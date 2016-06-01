tt<-read.table("common_assoc.txt",header=T,sep="\t")
pvals<-tt$P
observed <- sort(pvals)
lobs <- -(log10(observed))
 
 expected <- c(1:length(observed)) 
 lexp <- -(log10(expected / (length(expected)+1)))
 
 
 
pdf("qqplot_common_vars.pdf", width=6, height=6)
 plot(c(0,7), c(0,7), col="red", lwd=3, type="l", xlab="Expected (-logP)", ylab="Observed (-logP)", xlim=c(0,7), ylim=c(0,7), las=1, xaxs="i", yaxs="i", bty="l")
 points(lexp, lobs, pch=23, cex=.4, bg="black")
dev.off()
