setwd("/home/kr/Documents/Cours/Cours_2AE/Statistiques/fiche/chap/1chap/2sec/2exerecisesR")
#Importation of necassary libraries
library(MASS)
library(ISLR)
library(car)
#===============================================================================================
sink("/home/kr/Documents/Cours/Cours_2AE/Statistiques/fiche/chap/1chap/2sec/2exerecisesR/2lec.R")

#Q8)
#8.a)
#To perform simple linear regression with mpg as response and 
#horsepower as predictor
lm.fit = lm(mpg~horsepower, data=Auto)
summary(lm.fit)
#To get the predicted value of mph assuming horsepower=98
#?????
#To get the associated 95% confidence and predictions intervals:
attach(Auto)
predict(lm.fit, data.frame(horsepower=98), interval="confidence")
predict(lm.fit, data.frame(horsepower=98), interval="prediction")
#8.b)
#To plot the response and the predictors and the least squares
#regression fit
plot(horsepower, mpg, col='red', pch='+')
abline(lm.fit, lwd=3, col='green')
#8.c)
#To produce diagnostic plots of the least squares regression fit
par(mfrow=c(2,2))
plot(lm.fit)
plot(predict(lm.fit), residuals(lm.fit))
plot(horsepower, residuals(lm.fit))#To identify Non-linearity for a 
#simple regression
plot(residuals(lm.fit), type='o', col='blue')#To check if it exists
#any correlation of error terms
#Q9)
#9.a)
#To get a scatterplot matrix including all the variable in the data set
pairs(Auto)
#9.b)
#To compute the matrix of correlation using all variables but names
Table = data.frame(Auto)
Table[, -9]
cor(Table[, -9])
#9.c)
#To perform multiple linear regression with mpg as the response and
#all the predictors but names
lm.fit = lm(mpg~.-name, data=Auto)
summary(lm.fit)
plot(lm.fit, residuals(lm.fit), type='o', col='blue')
y_predict = predict(lm.fit)
plot(y_predict, residuals(lm.fit), type='o', col='blue')#To identify
#non-linearity problem for a multiple regression
plot(residuals(lm.fit), type='o', col='blue')#To check if it exists
#colinearity of error terms

sink()
#===============================================================================================
length(residuals(lm.fit))-length(lm.fit)
p=length(lm.fit)
lm.fit
y_predict = mpg - (coeffs[1]+coeffs[c(2:length(coeffs))]*Table[, c(2:n_coef)])
y_predict = mpg - (coeffs[c(2:length(coeffs))]*Table[, c(2:n_coef)])
head(y_predict)
s=0
for(i in 1:dim(Table)[1]){
	s[i] = as.matrix(cf)%*%as.matrix(Table[i, names(cf)])
	print(paste(s[i]))
}
n_coef = length(coeffs)

Table = data.frame(Auto)
lm.fit = lm(mpg~.-name, data=Auto)
coeffs0 = summary(lm.fit)$coefficients[,1]
coeffs=coeffs0[c(2:length(coeffs0))]
cf = coeffs[c(2:length(coeffs))]
y_predict=0
for(i in 1:dim(Table)[1]){
	k=0
	for(j in 1:length(cf)){
		k = k + cf[j]*Table[i, j]
	}
	y_predict[i] = k + coeffs0[1]
}
plot(y_predict, residuals(lm.fit), type='o', col='blue')
plot(residuals(lm.fit), col='blue')
plot(y_predict, type='o', col='blue')
plot(residuals(lm.fit), type='o', col='red')
warnings()
lm.fit
predict(lm.fit)
predict(lm.fit)-y_predict
par(mfrow=c(1,1))
plot(lm.fit)
mpg
