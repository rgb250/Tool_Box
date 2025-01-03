# Matplotlib

## 1. Plot successive subplots

```python
import pandas as pd
import matplotlib.pyplot as plt
import itertools

# df contains the response y in the first column and the features in the other ones
df = pd.read_csv('path_of_a_csv_file') 
y, X = df.iloc[:, 0], df.iloc[:, 1:]            # pretend X.shape[1] > 2
L = list(X)                                     # list of feature names   
ncols = 3                                       # desired number of columns
size = (35, 25)                                 # height, width

nrows = int(round(len(L)/ncols))                # minimum row number considering ncols
fig, ax = plt.subplots(nrows, ncols, figsize=size)
# over a 2D grid, horizontal: feature names, vertical: pairs being graph coordinates
for i,k in zip(itertools.product(np.arange(nrows), np.arange(ncols)), L):
    ax[i[0], i[1]].plot(X[k].values, y.values)  # plot a line curve each time
    ax[i[0], i[1]].set_title(k)                 
plt.show()
```

## 2. Labels
```python
.set_xticks()  # set the xaxis'tick location and optionally tick labels
```

# Seaborn
## Background
```python
import seaborn as sns
sns.set_style('darkgrid')
```




