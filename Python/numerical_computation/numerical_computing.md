# Numpy

## 1 dtype
```python
numpy.dtype  # to build numpy (or pandas) types, ex.: dtype('O')
```

## 2 Mask
```python
import numpy as np

ma = np.ma.MaskedArray(array, mask=cond)  # boolean array of same length as array, when cond is verified at a given a index, the resulting array will display True, otherwise False.
np.ma.average (ma, weights=array2)        # weighted average of array with array2 values. Only values for which cond was verified are taken in account.
```