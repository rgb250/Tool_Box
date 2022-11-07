# Argument Tips
## 1) Library *argparse*
We should not use the type convertor for boolean values!
If we want to play with the condition we can use the *sys* library
````
list_args = sys.argv[1:]  
keys = list_args[0::2]    
values = list_args[1::2]  
dct = {k: v for k, v in zip(keys, values)}
````
