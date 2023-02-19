setwd("/home/kr/Documents/Cours/Cours_2AE/Statistiques/fiche/chap/1chap/1sec/1exerecisesR")

print(paste("Euclidean function creation"))
EuclDist = function(x, y){
	#To acertain that we have 2 vectors of the same length.
	if (length(x)==length(y)){
		#s2 variable will be the sum of the squared difference of compoments
		s2=0
		for (i in 1:length(x)){
			s2=s2+(x[i]-y[i])^2
		}
		#s variable will be the euclidian distance
		s=sqrt(s2)
		return(s)
	}
	else{
		print(paste("Given vectors have different length"))
	}
}

print(paste("KNN function creation"))
KNN = function(x0, M, k){
	if(length(x0)==dim(M)[1]){
		#l variable will contain all euclidean distance between x0 and
		# vectors of cbind M
		l=c()
		for(j in 1:dim(M)[2]){
			l=c(l, EuclDist(x0,M[,j]))
		}
		#names of M columns are the class
		names(l)=colnames(M)
		#nearestN contains the neigborhood of x0
		nearestN=sort(l, decreasing=TRUE)[1:k]
		#class contain the name (the class) wich is the most common name
		class=sort(table(names(nearestN)),decreasing=TRUE)[1]
		return(names(class))
	}
}

M= cbind(c(0,3,0), c(2,0,0), c(0,1,3), c(0,1,2), c(-1,0,1), c(1,1,1))
colnames(M)=c("Red", "Red", "Red", "Green", "Green", "Red")

#===============================================================================================
sink("/home/kr/Documents/Cours/Cours_2AE/Statistiques/fiche/chap/1chap/1sec/1exerecisesR/1lec.R")

#EuclDist(c(1, 3),c(2, 4))
#print(paste(l))
print(paste("The result for K=1",KNN(c(0,0,0), M, 1)))
print(paste("The result for K=3",KNN(c(0,0,0), M, 3)))
sink()
#===============================================================================================

print(paste("The result for K=1", KNN(c(0,0,0), M, 1)))
print(paste("The result for K=3", KNN(c(0,0,0), M, 3)))
