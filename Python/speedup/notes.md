- [Multiprocessing](#multiprocessing)
  - [Introduction](#introduction)
- [Dask](#dask)
  - [Introduction](#introduction-1)
    - [Purpose](#purpose)
    - [Package to install with](#package-to-install-with)
  - [Data Ingestion](#data-ingestion)
  - [Deploy Dask Clusters](#deploy-dask-clusters)
    - [Local](#local)
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

## Dask Delayed

### Purpose

It allows to make the  custom computations lazy, 