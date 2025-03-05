# Table of contents

# Base environment

Should contain the strict minimum packages.
In order to be able to always download and reach package repositories it is good to run time to time in the **base** environment:

```bash
conda update --all
```

# Python

## Installing different requirements.txt with pip update

````bash
python -m pip install -r requirements.txt  # install packages, handle pip update
````

## Installing from a ``.conda`` file

````bash
conda install /path/file.conda
````

## For Windows

### Important modules

- **MKL** (Math Kernel Library)
  - It is a computing math library of highly optimized extensively threaded routines

  ````bash
    conda install mkl
  ````
