- [Assertions](#assertions)
  - [Look forward](#look-forward)
  - [Look backward](#look-backward)
  - [Negation](#negation)
- [Greedy notion](#greedy-notion)
  - [Greedy approach](#greedy-approach)
  - [Lazy approach](#lazy-approach)
- [Substitution](#substitution)
  - [With patterns](#with-patterns)

# Assertions

## Look forward

Search for an expression following a given expression.

```python
import re
text = '1: hello world, 2: HELLO WORLD'
pattern = re.compile('(?<=1:\s).*')  # returns all we have after "1: "
pattern.search(text) 
```

## Look backward

Search for an expression following a given expression.

```python
import re
text = '1: hello world, 2: hello world'
pattern = re.compile('.*(?=2:)')  # returns all we have before "2:"
pattern.search(text)
```

## Negation

- ``(?!...)``: is in the same logic of *Look **forward*** but it will display all the elements
that do not have *...* before them
- ``(?<!...)``: is in the same logic of *Look **backward*** but it will display all the
elements that do not have *...* after them

# Greedy notion

````python
import re

string = 'This is a <EM>first</EM> test.'
"""The objective is to capture flags '<EM>' and </EM>"""

re.match(string, r'<.+>')   # returns "<EM>first</EM>", it is a greedy approach
re.match(string, r'<.+?>')  # returns "<EM>", it is a non-greedy (or lazy) approach
````

## Greedy approach

In the above example ``+`` is **greedy**, it will cause the regex engine to repeat the
preceding token as often as possible.\
In more details the regex engine will proceed as below:

1. take in account the first token *<*
2. then apply the *.+*
   - each following character will be tested
   - until the end of the string
   - then the larger string section contained between *<* and *>* will be considered

## Lazy approach

This time:

1. take in account the first token *<*
2. then apply the *.+*
   - each following character will be tested
   - at the first occurrence of *>* the search will be stopped

# Substitution

## With patterns

```python
import re
pattern = re.compile(r'(\d+\s*)(k)(\s*)')
pattern.sub(r'\1 000\3', '2k ')    # '2 000 '
pattern.sub(r'\g<1>000\3', '2k ')  # '2000 ' useful when we put number just after a group
```
