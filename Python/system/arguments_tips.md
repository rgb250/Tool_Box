# Argument Tips
## 1) Library *argparse*

### a. Storing arguments
```python
argument = argparse.Arguments(description='List of arguments to run project P.')
parser.add_argument(
    '--arg1', dest='argument1', action='store', default='value1',
    help='Argument1 description...')
args = parser.parse_args()
print(args.argument1)
```
### b. Checking stored arguments
We should not use the type convertor for boolean values!
If we want to play with the condition we can use the ``sys`` library.
````python
import sys                                  # provide access to variables and functions interacting with interpreter

list_args = sys.argv[1:]                    # [arg1, val1, ..., argN, valN]
keys = list_args[0::2]                      # list of arguments
values = list_args[1::2]                    # list of argument values 
dct = {k: v for k, v in zip(keys, values)}  # dictionary mapping each argument with its value
````

# File systems
Moving across files
```python
path = os.path.abspath(path) # adapting the path to the operating system
file = os.path.join(path, 'file_name')  # concatenate paths
# create directory if it does not already exist:
if not os.path.exists(dir):
	os.path.makedirs(dir)

print(f'Current working directory {os.getcwd()}')
os.chdir(new_path)  # change working directory
```


# Packages
```python
import pkg_resources  # provide information about packages

print(pkg_resources.get_distribution('xlrd').version)
```
