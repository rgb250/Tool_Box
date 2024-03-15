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