dataF=read.csv("College.csv")
#fix(dataF)
rownames(dataF)=dataF[,1]
dataF = dataF[,-1]
setwd("/home/kr/Documents/Cours/Cours_2AE/Statistiques/fiche/chap/1chap/1sec/1exerecisesR")
#===============================================================================================
sink("/home/kr/Documents/Cours/Cours_2AE/Statistiques/fiche/chap/1chap/1sec/1exerecisesR/2lec.R")
summary(dataF)
sink()
#===============================================================================================
#pairs(dataF)
plot(dataF[,c("Private", "Outstate")])
Elite = rep("No", nrow(dataF))
Elite[dataF$Top10perc > 50]= "Yes"
Elite = as.factor(Elite)
dataF = data.frame(dataF, Elite)
summary(dataF[,'Elite'])
plot(dataF[,c('Outstate', 'Elite')])
#hist(dataF)
#hist(dataF[, c('Apps', 'Accept', 'Enroll', 'Top10perc')], par(mfrow=c(2,2)))
#N=apply(is.na(M),2,sum)
#par(mfrow=c(2,2))
#hist(dataF[,'Apps'])
#hist(dataF[,'Accept'])
#hist(dataF[,'Enroll'])
#hist(dataF[,'Top10perc'])

par(mfrow=c(2,2))
listNames=sample(colnames(dataF)[,-c('Private', 'Elite')], 4)
for(k in listNames){
	hist(dataF[, k], main=k)
}
