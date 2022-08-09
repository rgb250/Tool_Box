setwd("/home/kr/Documents/Cours/Cours_2AE/Statistiques/fiche/chap/1chap/2sec/2exerecisesR")

library(MASS)
library(ISLR)
library(car)
#===============================================================================================
sink("/home/kr/Documents/Cours/Cours_2AE/Statistiques/fiche/chap/1chap/2sec/2exerecisesR/1lec.R")

#SIMPLE REGRESSION
#To get a Boston data as spreadsheet.
#fix(Boston)
?Boston #To get information about Boston variable.
#To perform a simple regression between medv (response) and lstat (predictor)
lm.fit = lm(medv~lstat, data=Boston)
#For more detailed information about the model:
summary(lm.fit)
coef(lm.fit) #To get coefficient estimates for simple regression
confint(lm.fit) #To get confidence interval for the coefficient estimates
attach(Boston)
#To get confidence interval:
predict(lm.fit, data.frame(lstat=c(5, 10, 15)), interval="confidence")
#To get prediction interval:
predict(lm.fit, data.frame(lstat=c(5, 10, 15)), interval="prediction")
#To plot 
plot(lstat, medv, col='red', pch='+')
abline(lm.fit, lwd=3, col='green')
#To plot 'Residuals vs Fitted', 'Normal Q-Q', 'Scale Location' and
#'Residuals vs Leverage'.:
par(mfrow=c(2,2))
plot(lm.fit)
plot(predict(lm.fit), residuals(lm.fit))
plot(predict(lm.fit), rstudent(lm.fit))
plot(hatvalues(lm.fit))

#MULTIPLE REGRESSION 
#To make a multiple regression over all the predictors of Boston data
lm.fit = lm(medv~., data=Boston)
summary(lm.fit)
#To get the variance inflation factor
vif(lm.fit)
#To update
update(lm.fit, ~.-age)

#INTERACTION TERMS
summary(lm(medv~lstat*age, data=Boston))

#NON-LINEAR TRANSFORMATION OF THE PREDICTORS
lm.fit2 = lm(medv~lstat+I(lstat^2))
summary(lm.fit2)
#'anova' function allows to quantify the extent to which the quadratic
#fit lm.fit2 is superior to the linear fit lm.fit
anova(lm.fit, lm.fit2)
#To create polynomial fit:
lm.fit5 = lm(medv~poly(lstat, 5))
summary(lm.fit5)
plot(lstat, medv, col='red', pch='+')
plot(lm.fit5)

#QUALITATIVE PREDICTORS
#fix(Carseats)
#names(Carseats)
#?Carseats
lm.fit =lm(Sales~.+Income:Advertising+Price:Age, data=Carseats)
summary(lm.fit)
#'contrast()'function returns the coding that R uses for dummy variabes
attach(Carseats)
contrasts(ShelveLoc)

#WRITING FUNCTIONS

sink()
#===============================================================================================
