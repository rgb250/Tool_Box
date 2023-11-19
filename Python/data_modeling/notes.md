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
### 2) Evaluate it
- Silouhette algorithm: for a given method

# spaCy
## Download a pre-trained pipeline
Some spaCy's features need *trained pipelines* to be loaded, which enable 
*spaCy to predict linguistic* annotations (whether a word is a verb or a 
noun). The below line allows to download the *en_core_wb_sm* pipeline.
```bash
python -m spacy dowload en_core_wb_sm
```
## Use of features
```python
import spacy
nlp = spacy.load('en_core_wb_sm')

doc = nlp("The science cannot provide the truth of the Universe, even not sure that 1+1=2 is an universal truth.")
df_doc = pd.DataFrame([
    {
        'text': token.text,       # original text
        'pos': token.pos_,        # part-of-speech (verb, proposition...)
        'tag': token.tag_,        # detail part-of-speech 
        'dep': token.dep_,        # syntactic dependency 
        'shape': token.shape_,    # capitalization, punctuation, digits ..
        'alpha': token.is_alpha,  # is the token alpha character?
        'stop': token.is_stop     # stop list = list of most common words
    } for token in doc
])
```