#  TABLE OF CONTENTS
- [TABLE OF CONTENTS](#table-of-contents)
  - [1 SEARCH](#1-search)
    - [a. Options](#a-options)
      - [Sensitivity](#sensitivity)
      - [Whole word](#whole-word)
  - [2 FORMAT](#2-format)
    - [a. Change the case](#a-change-the-case)
  - [3 DISPLAY OPTIONS](#3-display-options)
    - [a. Open multiple file](#a-open-multiple-file)
    - [b. Window operations](#b-window-operations)
    - [c. Compare 2 files](#c-compare-2-files)
  - [4 FILE SYSTEM INFORMATION](#4-file-system-information)
    - [a. Current file](#a-current-file)
  - [5 MACRO](#5-macro)
    - [a. To a block](#a-to-a-block)


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
### a. Open multiple file 
```bash
vim -O file1 file2 file3  # open in vertical split the 3 files
vim -o file1 file2 file3  # open in horizontal split the 3 files
```
### b. Window operations 
To each window to synchronize
```bash
:set scrollbind
```
### c. Compare 2 files
- open one file
  ````bash
  vim path_file_1
  ````
- inside vim type
  ````vim
  :vert diff path_file_2
  ````

## 4 FILE SYSTEM INFORMATION
### a. Current file
```bash
:f
```

## 5 MACRO
### a. To a block
Apply a macro **a** to a multiple lines.
```normal
:'<,'>normal @a
```
## 6 Spellcheck
### a. Relevant plugins
- [vim-lexical](https://vimawesome.com/plugin/vim-lexical) (spelling)
- [LanguageTool](https://vimawesome.com/plugin/languagetool) (grammar)