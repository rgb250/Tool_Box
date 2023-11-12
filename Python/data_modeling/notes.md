# Scikit-Learn
## Steps 
### 1) Formatting the data
### 2) Train/Test datasets
```python
from sklearn.model_selection import train_test_split
```

## Classification
### 1) Assessing
- Confusion matrix

## Clustering
### 1) Algorithms

Use one of the following algorithm
```python
from sklearn import cluster

list_algo_cluster = [
    cluster.MeanShift(),
    cluster.MiniBatchKMeans(),
    cluster.AgglomerativeClustering(),
    cluster.SpectralClustering(),
    cluster.DBSCAN(),
    cluster.HDBSCAN(),
    cluster.OPTICS(),
    cluster.AffinityPropagation(),
    cluster.AgglomerativeClustering(),
    cluster.Birch(),
    cluster.GaussianMixture(),
]
```
