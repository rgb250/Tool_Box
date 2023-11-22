# Assertions
## Look forward
Search for an expression following a given expression.
```python
import re
text = '1: hello world, 2: hello world'
pattern = re.compile('(?<=1: )hello world', text)  # returns the first 'hello world'
```
## Look backward
Search for an expression following a given expression.
```python
import re
text = '1: hello world, 2: hello world'
pattern = re.compile('hello world(?=, )', text)  # returns the first 'hello world'
```
## Negation
You just need to change *'?<='* or *'?='* with **'?!'**