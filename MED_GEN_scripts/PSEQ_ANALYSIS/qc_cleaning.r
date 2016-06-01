tt<-read.table("istats.txt",header=T)
pdf("call_rate.pdf")
hist(tt$RATE,breaks=20,main="Variant Call Rate",xlab="Rate")
dev.off()

indiv<-read.table("/data/SBW2016/Nikita/NIKITA/EXOME_SEQ/PSEQ/pop_struct.phe",sep="\t")
case<-as.character(unlist(indiv[which(indiv[,2]==2),1]))
control<-as.character(unlist(indiv[which(indiv[,2]==1),1]))
pdf("nhet.pdf")
hist(tt[which(is.element(tt[,1],case)==TRUE),4],breaks=20,col=rgb(1,0,0,0.5))
hist(tt[which(is.element(tt[,1],control)==TRUE),4],breaks=20,col=rgb(0,1,0,0.5),add=T)
dev.off()

rm_indiv<-as.character(unlist(tt[which(tt$RATE<=0.9),1]))
tt<-tt[which(is.element(tt[,1],rm_indiv)==FALSE),]

pdf("call_rate_cleaned.pdf")
hist(tt$RATE,breaks=20,main="Variant Call Rate",xlab="Rate")
dev.off()

pdf("nhet_cleaned.pdf")
hist(tt[which(is.element(tt[,1],case)==TRUE),4],breaks=20,col=rgb(1,0,0,0.5))
hist(tt[which(is.element(tt[,1],control)==TRUE),4],breaks=20,col=rgb(0,1,0,0.5),add=T)
dev.off()

write.table(rm_indiv,"rm_indiv.txt",row.names=F,col.names=F,quote=F)


