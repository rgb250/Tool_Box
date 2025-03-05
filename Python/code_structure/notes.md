- [Recursive function](#recursive-function)
  - [Introduction](#introduction)
  - [Exemple](#exemple)
- [Positional Arguments (args) and KeyWordsArguments (kwargs)](#positional-arguments-args-and-keywordsarguments-kwargs)
- [Module](#module)
- [Object Oriented Programming](#object-oriented-programming)
  - [Naming convention](#naming-convention)
- [Decorators](#decorators)
  - [@property](#property)

# Recursive function

## Introduction

Amongst the appealing points of recursive functions we have:

- simplicity over nested iterations
- gain of effectivity compare with some standard approaches

## Exemple

````python
""" This code allows to collect the file contained in a root folder and its child folders depending on file extension. """
import re
import os


def retrieve_file(
  path_root: str,
  list_to_add: list[str] = [],
  pattern_file: re.compile = re.compile(r'.*\.pkl$')
) -> list[str]:
    """
    Python equivalent of Linux command $(find -type f -regex '.*/.*\.pkl$') for default value of
    <pattern_file>
    Parameters:
    -----------
    path_root: str
      The initial path from which to start the greedy file search.
    list_to_add: list[str]
      The list in which we will collect the files matching with the pattern.
    pattern_file: re.compile = re.compile(r'.*\.pkl$')
      Pattern allowing to target wanted files.

    Return:
    -------
      list containing all the file matching with the pattern <pattern_file>
    """

    list_path_folder = [                      # list sub-folders
      os.path.join(path_root, item) for item in os.listdir(path_root) 
      if os.path.isdir(os.path.join(path_root, item))
    ]
    list_path_file = [                        # list files contained in root folder
      os.path.join(path_root, item) for item in os.listdir(path_root) 
      if os.path.isfile(os.path.join(path_root, item)) and pattern_file.match(item)
    ]
    list_to_add += list_path_file             # add files found in list_path_file
    for folder in list_path_folder:
      """" 
      Here is the magic: we will recursively apply the above search to the sub-folders contained 
      in list_path_folder and progressively enrich <list_to_add>. 
      The algorithm will stop when list_path_folder is empty, meaning when there are not anymore
      child folders.
      """
        retrieve_file(path_root=folder, list_to_add=list_to_add)
    return list_to_add
````

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
    return result
  return wrapper

@timer
def read_excel_timer(*args, **kwargs):
  return pd.read_excel(*args, **kwargs)

````

## @property

It allows to use method, as attributes, it is useful when we use methods without arguments
