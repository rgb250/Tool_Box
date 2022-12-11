# Table of Content


## 1) Introduction
There are **3** main type of feature selection methods:
- **Filter**: uses a proxy measures (like mutual information) instead of the error rate, therewith to be fast to compute. Actually it looks at each feature individually or compare them to other features then assesses how important they are. This method has  also been used as a preprocessing step for wrapper methods.
- **Wrapper**: uses a *predictive model* to score feature subsets. Examine almost all possible feature combinations to identify the optimal feature subset.
- **Embedded**: perform feature selection as part of the model construction process, for example *Lasso*. They are less computationally costly then wrapper methods
- **Hybrid methods**: A mix of the 3 above types of feature selection methods.


## 2) Filter 
Among the best measure for feature selection method of filter type are:
- *Mutual Information*: measures the mutual dependence between tow variables. It is more general than the correlation, because it is not focus on linear association.
- *Fisher score*: uses the $\chi^{2}$ distribution to measure the dependency between two variables and works with *categorical* variables.
- *ANOVA* measure the dependencies between 2 *continuous variables* and requires a *binary target*.
- *ROC-AUC/RMSE*: measure the performance of a model for either *classification* and *regression*.

## 3) Wrapper
Start by searching through different subset of features, then creating a model with each.
- *Step forward feature selection*
- *Step backward feature selection*
- *Exhaustive search*: it tries all combinations of features.

## 4) Embedded
- *Lasso*
- *Regression coefficients*: same principle as Lasso, except that a scaling step is necessary.
- *Decision tree feature importance*: random forest and decision trees provide good predictive performance, low overfitting and easy interpretability.

# Hybrid methods
- *Recursive feature elimination*: 
  1. Ranking features thanks to embedded method.
  2. Remove the least important feature and build a new machine learning algorithm.
  3. Compute performance metric such as ROC-AUC, MSE, ...
  4. If the metric decrease buy more than an arbitrary set threshold we should keep it otherwise remove it. 
- *Recursive feature addition*: 
  1. Ranking features thanks to embedded method.
  2. Build a model with only the one most important features.
  3. Compute performance metric such as ROC-AUC, MSE, ...
  4. Add the second most relevant feature and train the model and build a new machine learning algorithm.
  5. If the metric decrease buy more than an arbitrary set threshold we should keep it otherwise remove it. 
This last method is a good compromise, but the threshold has to be find.