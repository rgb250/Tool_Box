#  TABLE OF CONTENTS
1. [SEARCH](##1-search)
    - [a. Options](#a-options)
2. [FORMAT](#2-format)
    - [a. Change the case](#a-change-the-case)
3. [DISPLAY OPTIONS](#3-display-options)
    - [a. Window operations](#a-window-operations)
4. [FILE SYSTEM INFORMATION](#4-file-system-information)
    - [a. Current file](#a-current-file)


## 1 SEARCH
### a. Options
#### Sensitivity

```bash
/\Cword_to_search  # to respect the case
```
```bash
/\Cword_to_search  # ignore the case
```
#### Whole word
```bash
/\<word_to_search\>  # match just the exact word
```

## 2 FORMAT
### a. Change the case
Visual mode + type 'u' to impose lower case and 'U' to impose upper case.

## 3 DISPLAY OPTIONS
### a. Window operations 
To each window to synchronize
```bash
:set scrollbind
```

## 4 FILE SYSTEM INFORMATION
### a. Current file
```bash
:f
```
