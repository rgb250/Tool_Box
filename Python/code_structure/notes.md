- [Module](#module)
- [Object Oriented Programming](#object-oriented-programming)

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