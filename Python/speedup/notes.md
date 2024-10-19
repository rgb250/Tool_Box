- [Multiprocessing](#multiprocessing)
  - [Introduction](#introduction)
- [Dask](#dask)
  - [Introduction](#introduction-1)
    - [Purpose](#purpose)
    - [Package to install with](#package-to-install-with)
  - [Data Ingestion](#data-ingestion)
  - [Deploy Dask Clusters](#deploy-dask-clusters)
    - [Local](#local)
  - [Dask collections](#dask-collections)
    - [Dask Array](#dask-array)
    - [Dask Bags](#dask-bags)
    - [Dask DataFrames](#dask-dataframes)
  - [Dask Delayed](#dask-delayed)
    - [Purpose](#purpose-1)

# Multiprocessing

## Introduction

``multiprocessing`` package offers convenient ways to spawn processes in parallel.
For example *Pool* object allows to:

- parallelizing the execution of a function across different input data
- distributing the input data across processes

# Dask

## Introduction

### Purpose

This library will split objects named ``collections`` in different *partitions*, then depending
on the instruction provided in the input function it will establish a strategy materialized by a
task graph. Finally the real computation will occur once users will ask for it.

![001_dask_intro_graph](./images/001_dask_intro_graph.png)

### Package to install with

- ``graphviz``, complex installation on Windows
- ``ipycytoscape`` 
- ``nodjs``
- ``dask-labextension``: [dask-labextension](https://github.com/dask/dask-labextension)

## Data Ingestion

````python
import dask.dataframe as dd

ddf = dd.read_csv('large_file.csv', blocksize=25e6) 
````

A good rule of thumb is **working on partitions weighting less than 100MB**.

## Deploy Dask Clusters

### Local

````python
from dask.distributed import LocalCluster

cluster = LocalCluster()       # fully-featured local Dask cluster
client = cluster.get_client()
````

## Dask collections

### Dask Array

This collection coordinates many Numpy array arranged into chunks within a grid:\
![001_dask_intro_array](./images/001_dask_intro_array.png)

````python
import dask.array as da

x = da.random.random
````

### Dask Bags

This object implements operations like ``map``, ``filter``, ``groupby`` and
*aggregation* on collections of Python objects. It can be viewed as a **parrallel
version of ``itertools``**.

Very useful to work with dictionaries.

````python
import dask.bag as db
import json

bag = db.read_text('json_file_to_read').map(json.loads)  # uses the json.loads method
bag.map(lambda record: record['occupation']).take(2)     # take() allows to select the number of first elements to consider
````

### Dask DataFrames

This object coordinates many Pandas dataframes, partitioned along an index:\
![001_dask_intro_dataframe](./images/001_dask_intro_dataframe.png)

- **Groupby Apply with Scikit-Learn**

  ````python
  from sklearn.linear_model import LinearRegression

  def train(partition):
    if not len(partition):
      return
    model = LinearRegression()
    model.fit(partition[['x']].values, partition['y'].values)
    return model

  df_agg_mod = (
    df
    .groupby('name')
    .apply(train, meta=(name='LinearRegression', dtype=object))  # Pandas will store the result as a general object
    .compute()
  )
  ````

The ``meta`` argument tells Dask how to create the DataFrame or SEries that will
hold the result of ``apply()``. Here *train()* returns a single value so *apply()*
will create a *Series*.

## Dask Delayed

### Purpose

It allows to make the  custom computations lazy, 