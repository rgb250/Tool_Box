- [Module](#module)
- [Object Oriented Programming](#object-oriented-programming)
  - [Naming convention](#naming-convention)
- [Decorators](#decorators)
  - [@property](#property)

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

## @property

It allows to use method, as attributes, it is useful when we use methods without arguments
