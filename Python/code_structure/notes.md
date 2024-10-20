- [Positional Arguments (args) and KeyWordsArguments (kwargs)](#positional-arguments-args-and-keywordsarguments-kwargs)
- [Module](#module)
- [Object Oriented Programming](#object-oriented-programming)
  - [Naming convention](#naming-convention)
- [Decorators](#decorators)
  - [@property](#property)

# Positional Arguments (args) and KeyWordsArguments (kwargs)

- Positional arguments are the ones identified by their position in the argument
list in a function definition scope without  default values associated with.
- Keywords arguments are the ones identified via a keywords, they have a default value associated with

````python
def foo(arg1, arg2, key3=None, key4=None)
  """ arg1 and arg2 are positional arguments whereas key3 and key4 are the keyword arguments"""
  ....
  return ....
````

# Module

Imagine in a file we created many methods: *method_1*, ..., *method_m*, and now want to access
them in a friendly way.
A good practice is to gather the created methods in a file, let say **created_module.py**,
put it in a folder like **created_lib** then create an empty file name `__init__.py` like here:

|    __init__.py\
|\
└───created_lib
        created_module

````python
from created_lib import created_module  as cm # we can then use cm.method_1
````

# Object Oriented Programming

## Naming convention

````python
_single_leading_underscore    # from M import * does not import objects whose names start with an _
single_trailing_underscore_   # prevent conflict with Python's keywords
__double_leading_underscore   # when naming a class attribute invokes name (inside class FooBar __boo becomes _FooBar__boo)
__double_leading_and_trailing_underscore__  # 'magic' objects or attributes that live in user-controlled namespaces
````

# Decorators

It takes in input a function and extends its behavior.

````python
import numpy as np
import functools

def timer(func):
  @functools.wraps(func)  # preserves the information about initial function <func>
  def wrapper(*args, **kwargs):
    duration = np.repeat(-time(), 2)
    result = func(*args, **kwargs)
    dur = duration.sum()
    qh, rm = divmod(dur, 3600)
    qm, rs = divmod(rm, 60)
    logger.info(f'Elapsed time to run {fun.__name__}: {qh:.0f}h:{qm:.0f}m:{rs:.0f}s')
    return obj
  return wrapper

@timer
def read_excel_timer(*args, **kwargs):
  return pd.read_excel(*args, **kwargs)

````

## @property

It allows to use method, as attributes, it is useful when we use methods without arguments
