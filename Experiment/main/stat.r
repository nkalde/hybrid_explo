#! /usr/bin/env Rscript

args <- commandArgs(TRUE)
rawData <- read.table(args[1], header=FALSE, col.names=c("exp","com","cor","dis","tim","frA","inA","prI","alp","sig","cnt"))
#rawData <- read.table("cave_den0_assMRFBE_MinDist_dec_.dat", header=FALSE, col.names=c("exp","com","cor","dis","tim","frA","inA","prI","alp","sig","cnt"))
#"exp","com","cor","dis","tim","frA","inA","prI","alp","sig","cnt"
#factorAlpha = factor(rawData$alp)

rawData$alpsig <- paste(rawData$alp,rawData$sig,sep="_")
  
for(i in names(rawData)[2:7]) {
  rawData[[paste(i, 'mean',sep="_")]] <- ave(rawData[[i]],rawData$alpsig,FUN=mean)
  rawData[[paste(i, 'sd',sep="_")]] <- ave(rawData[[i]],rawData$alpsig,FUN=sd)
  #rawData[[paste(i, 'max',sep="_")]] <- ave(rawData[[i]],rawData$alpsig,FUN=min)
  #rawData[[paste(i, 'sd',sep="_")]] <- ave(rawData[[i]],rawData$alpsig,FUN=max)
}

colNames <-c('alp',"sig","com_mean","com_sd","dis_mean","dis_sd","tim_mean","tim_sd","frA_mean","frA_sd","inA_mean","inA_sd")
rawData <- unique(rawData[colNames])

#print(args[1])
nfile <- paste(args[1],'r',sep='.')
#write.table(rawData, file=nfile,row.names=FALSE,col.names=FALSE)

write.table(rawData, file=nfile,row.names=FALSE)