- [Selenium](#selenium)
  - [Basics](#basics)
    - [Essential libraries](#essential-libraries)
    - [Accessing pages](#accessing-pages)
    - [Find elements](#find-elements)
- [BeautifulSoup](#beautifulsoup)
  - [Basics](#basics-1)

# Selenium

##  Basics 

### Essential libraries
```python
from selenium import webdriver                   # module providing WebDriver implementations
from selenium.webdriver.common.keys import Keys  # keyboard features
from selenium.webdriver.common.by import By      # useful for attribute search
```

### Accessing pages

```python
driver = webdriver.Firefox()          # browser choice
driver.get('https://www.google.fr/')  # url to start with
driver.close()                        # close driver once you're done
```

### Find elements


# BeautifulSoup

## Basics
Think to install a parser like `lxml`
```python
conda install lxml
```
