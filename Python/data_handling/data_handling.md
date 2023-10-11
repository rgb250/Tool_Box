# Multi-index
```python
import pandas as pd

df = pd.DataFrame(np.random.random((4, 4)))
df.columns = pd.MultiIndex.from_product([[1, 2], ['A', 'B']])
""""
  +===============+==============+
  |       1       |       2      |
  +---------------+--------------+
  |   A   |   B   |  A    |  B   |
  +=======+=======+=======+======+
0 | 0.544 | 0.628 | 0.757 | 0.7  |
  +-------+-------+-------+------+
1 | 0.633 | 0.896 | 0.198 | 0.784|
  +-------+-------+-------+------+
2 | 0.662 | 0.541 | 0.544 | 0.059|
  +-------+-------+-------+------+
3 | 0.841 | 0.635 | 0.815 | 0.848|
  +=======+=======+=======+======+ 
"""

df.iloc[:, df.columns.get_level_values(1) == 'A']
"""
  +===============+
  |   A   |  A    |
  +=======+=======+
0 | 0.544 | 0.757 |
  +-------+-------+
1 | 0.633 | 0.198 |
  +-------+-------+
2 | 0.662 | 0.544 |
  +-------+-------+
3 | 0.841 | 0.815 |
  +=======+=======+ 
"""
```

# Concatenate
```python
import pandas as pd

df = pd.read_csv('path_of_a_csv_file')
list_cols_to_concatenate = list(df.iloc[:, 1:4])
df[‘concatenated_cols’] = df[list_cols_to_concatenate].astype(str).agg(‘-’.join, axis=1)
```

# Display in Jupyter

```python
import pandas as pd
from IPython.display import display
with pd.option_context('display.max_rows', 100, 'display.max_columns', 10):
    display(df)
```