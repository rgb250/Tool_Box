#!/bin/bash

source /home/kr/Documents/Cours/Cours_2AE/Statistiques/fiche/configDoss/configFunctions.sh
#=====================================================================
#CRÉATION DE LA PARTIE CONSIDÉRÉE
initialisation "1" "introductionToStatisticalLearning" "Introduction to Statistical Learning"
#=====================================================================
#CRÉATION DES FICHIERS CENTRALISANT CHAQUE CHAPITRE 
declare -a chap=("StatisticalLearning" "LinearRegression" 
"Classification" "ResamplingMethods" 
"LinearModelSelectionAndRegularization" "MovingBeyondLinearity"
"TreeBasedMethods" "SupportVectorMachines" "UnsupervisedLearning")
declare -a nChap=("Statistical Learning" "Linear Regression" 
"Classification" "Resampling Methods" 
"Linear model selection and regularization" "Moving beyond linearity"
"Tree-based-methods" "Support vector machines" "Unsupervised learning")
declare -a newChap=()
initialisation2
#Déclaration de variables
declare -a files=()
declare -a nFiles=()
#CRÉATION DES 4 SECTIONS DU CHAPITRE 1
files=( "1" "whatIsStatisticalLearning" "assessingModelAccuracy"
"introductionToR" "Exercises")
nFiles=("What is statistical Learning?" "Assessing Model Accuracy"
"Introduction to R" "Exercises")
creation

#CRÉATION DES 4 SECTIONS DU CHAPITRE 2
files=("2" "simpleLinearRegression" "multipleLinearRegression"
"otherConsiderationsInTheRegressionModel"
"theMarketingPlan" "comparisonOfLinearRegressionWithK_NearestNeighbors"
"labLinearRegression" "exercises")
nFiles=("Simple linear regression" "Multiple linear regression"
"Other considerations in the regression model" "The marketing plan"
"Comparison of linear regression with K-Nearest neighbors"
"Lab: linear regression" "Exercises")
creation
##CRÉATION DES 4 SECTIONS DU CHAPITRE 3
files=("3" "anOverviewOfClassification" "whyNotLinearRegression"
"logisticRegression" "linearDiscriminantAnalysis" 
"aComparisonOfClassificationMethods" "labLogisticRegressionLDA_QDA_KNN"
"exercices")
nFiles=("An overview of classification" "Why not linear regression ?"
"Logistic regression" "Linear discriminant analysis" 
"A comparison of classification methods"
"Lab: logistic regression LDA, QDA and KNN" "Exercises")
creation
##CRÉATION DES 3 SECTIONS DU CHAPITRE 4
files=("4" "crossValidation" 
"theBootstrap" "labCrossValidationAndTheBootsrap" "exercises")
nFiles=("Cross-validation" 
"The Bootstrap" "lab: Cross-validation and the Bootsrap" "Exercises")
creation
##CRÉATION DES 4 SECTIONS DU CHAPITRE 5
files=("5" "subsetSelection" "shrinkageMethods" 
"dimensionReductionMethods"
"considerationInHighDimensions" "lab1SubsetSelectionMethods"
"lab2RidgeRegressionAndTheLasso" "lab3PCRandPLSregression" "exercises")
nFiles=("Subset selection" "Shrinkage methods" 
"Dimension reduction methods"
"Consideration in high dimensions" "Lab1: subset selection methods"
"Lab2: ridge regression and the Lasso"
"lab3: PCR and PLS regression" "Exercises")
creation
##CRÉATION DES 9 SECTIONS DU CHAPITRE 6
files=("6" "polynomialRegression" "stepFunctions" "basisFunctions"
"regressionSplines" "smoothingSplines" "localRegression"
"generalizedAdditiveModels" "labNonLinearModeling" "exercises")
nFiles=("Polynomial Regression" "Step functions" "Basis functions"
"Regression splines" "Smoothing splines" "Local regression"
"Generalized additive models" "lab: Non-linear modeling" "Exercises")
creation
##CRÉATION DES 4 SECTIONS DU CHAPITRE 7
files=("7" "theBasicsOfDecisionTrees" "bagging_RandomForest_Boosting" 
"labDecisionTrees" "exercises")
nFiles=("The basics of decision trees" 
"Bagging, RandomForest and Boosting" "Lab: decision trees" "Exercises")
creation
##CRÉATION DES 7 SECTIONS DU CHAPITRE 8
files=("8" "maximalMarginClassifier" "supportVectorsClassifiers" 
"supportVectorsMachines" "SVMsWithMoreThan2Classes" 
"relationshipToLogisticRegression" "labSupportVectorMachines" 
"exercises")
nFiles=("Maximal margin classifier" "Support vectors classifiers" 
"Support vectors machines" "SVMs with more than 2 classes" 
"Relationship to logistic regression" "lab: support vector machines" 
"Exercises")
creation
##CRÉATION DES 7 SECTIONS DU CHAPITRE 9
files=("9" "theChallengeOfUnsupervisedLearning" 
"principalCompomentsAnalysis" "clusteringMethods" 
"lab1PrincipalCompomentsAnalysis" "lab2Clustering" 
"lab3NCI60DataExample" "exercises")
nFiles=("The challenge of unsupervised learning" 
"Principal compoments analysis" "Clustering methods" 
"Lab1: principal compoments analysis" "Lab2: clustering" 
"Lab3: NCI60 data example" "Exercises")
creation
