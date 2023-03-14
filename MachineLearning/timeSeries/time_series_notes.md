# Time Series Notes

- [Time Series Notes](#time-series-notes)
  - [1) Introduction](#1-introduction)
    - [a. Time Series Definition](#a-time-series-definition)
    - [b. Stationarity](#b-stationarity)
    - [c. AutoCoVariance Funciton (ACVF)](#c-autocovariance-funciton-acvf)

## 1) Introduction
###  a. Time Series Definition
The observed data $\{x_{t}\}_{t\in\mathbb{N}^{*}}$ are seen as realization of the follwoing random variables $\{X_{t}\}_{t\in\mathbb{N}^{*}}$
### b. Stationarity
The time series $\{X_{t}\}_{t\in\mathbb{Z}}$ and its AutoCoVariance Function $\gamma_{X}$ is said to be *(weakly)* stationary if 
- $\forall t\in \mathbb{Z}, \exist M\in \mathbb{R}_{+}, \mathbb{V}(X_{t}) < M$
- $\exists! \mu \in \mathbb{R}, \forall t\in\mathbb{Z} ~\mathbb{E}(X_{t}) = \mu$ 
- $\forall (r, s, t) \in\mathbb{Z}^{3}~\gamma_{X}(r, s) = \gamma_{X}(r + t, s + t)$
### c. AutoCoVariance Funciton (ACVF) 
Let $\{X_{t}\}_{t\in\mathbb{Z}}$ be a *stationary time series* the ACF at $t=t_{0}$ is 
$$ \gamma_{X_{t=t_{0}}}(h) = Cov(X_{t_{0}+h}, X_{t_{0}})$$
The AutoCorrelation Function (ACF) is 
$\rho_{X}(h) = \dfrac{\gamma_{X_{t=t_{0}}}(h)}{\gamma_{X_{t=t_{0}}}(0)}$