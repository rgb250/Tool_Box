# What is it?

It is an analogous tool to `apt` in Linux distributions.\
When you download a package through `pipx` it creates an environment specifically to this
package, this environment is then considered like *isolated*.\
`pipx` downloads packages from the same sources than `pip` allowing to turn Python Package 
Index (**PyPI**) in a **big app store for Python applications**.

# Settings

Pay attention to provide a default Python isolated from the ones used in 
virtual environments.

````bash
export PATH_DEFAULT_PYTHON="path/to/independant/python"
````