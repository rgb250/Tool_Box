# Print format

## 1. Padding
### a Strings
```python
n = '4'
print(n.zfill(3))  # 004
```

### b. Numbers
```python
n = 4              # below methods display 004
print(f'{n: 03}')  # method preferred from Python 3.6
print('%03d' % n)  # valid across all Python versions
```

## Conversions with print format
|Symbol| Meaning                                                                     |
|:----:|:----------------------------------------------------------------------------|
|'d'   | Signed integer decimal                                                      |
|'o'   | Octal: number in base 8                                                     |
|'x'   | Hexadecimal (lower case): number in base 16                                 |
|'x'   | Hexadecimal (upper case): number in base 16                                 |
|'e'   | Exponential notation (lower case), ex.: 5.8e3                               |
|'E'   | Exponential notation (lower case), ex.: 5.8E3                               |
|'f'   | Fixed-point notation, ex.: for $p=2,~\pi\rightarrow 3.14$ and  *inf*, *nan* |
|'F'   | Fixed-point notation, ex.: for $p=2,~\pi\rightarrow 3.14$ and  *INF*, *NAN* |
|'g'   | General notation, uses (e) for large values, otherwise (f)                  |
|'G'   | General notation, uses (E) for large values, otherwise (F)                  |
|'%'   | Percentage, multiplies the number by 100                                    |
|'b'   | Binary format                                                               |
|'c'   | Character, converts the integer to the corresponding unicode character      |
|'s'   | String format, the default format                                           |

Exemple
```python
"int: {0:d};  hex: {0:#x};  oct: {0:#o};  bin: {0:#b}".format(42) # 'int: 42;  hex: 0x2a;  oct: 0o52;  bin: 0b101010'
```