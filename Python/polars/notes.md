# Select columns

````python
import polars as pl

df =  pl.DataFrame({
    'x': [i for i in range(11)],
    'y': [i**2 for i in range(11)]
}) 
````