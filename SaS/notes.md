- [Basics](#basics)
  - [Syntax](#syntax)
  - [Variables](#variables)
  - [Strings](#strings)
  - [Array](#array)
  - [Loop](#loop)
  - [Sub-setting](#sub-setting)
- [Macro](#macro)
- [File](#file)
  - [Read file](#read-file)
  - [Write file](#write-file)

# Basics

## Syntax

Some general rules:

- all statement end by ``RUN`` and always with a ``;``
- the keyword ``DATA`` allows to create temporary dataset
- local variable are declared with ``%let``

## Variables

- Numeric variables

  ````sas
  INPUT X1, X2, X3; * Numeric variable
  ````

- Character variables, adding a *space* and a ``$`` symbol at the end of
  the variable name assigns it a character type.

  ````sas
  INPUT VAR1 $ VAR2 $ VAR3 $;
  ````

- Date, we just have to add the data format at the end of the variable

  ````sas
  INPUT VAR1 MMDDYY10;
  ````

  |Input Date         | Date Width  | Format        |
  |-------------------|-------------|---------------|
  |14/11/2024         |10           |``mmddyy10.``  |
  |14/11/24           |10           |``mmddyy8.``   |
  |December 11, 2024  |20           |``worddate20.``|
  |14mar2024          |9            |``date9.``     |
  |14-mar-2024        |11           |``date9.``     |

## Strings

````sas
DATA str_ex;
    str1 = 'Hello';
    str2 = 'World';
    joined = str1 || str2;
RUN;

PROC PRINT DATA = str_ex;
RUN;
````

## Array

- Defining an array

    ````sas
    ARRAY AGE[5] (12, 18, 23, 59, 90);
    ARRAY QUESTS(1:5) $ Q1-Q5;  * Q1, ..,Q5
    ARRAY ANSWER(*) A1-A100;    * A1, ...,A100
    ````

- ``OF`` operator

    ````sas
    DATA arr_ex;
        INPUT a1, a2, a3, a4;
        ARRAY A(4) A1-A4;
        A_SUM = SUM(OF A(*));  * use to sum the entire row of an array
    RUN;
    PROC PRINT DATA = arr_ex;
    RUN;
    ````

## Loop

- ``DO``

    ````sas
    DATA mydata;
        sum = 0;
        DO var=1 to 5;
            sum = sum + var;
        END;
    RUN;

    PROC PRINT DATA = mydata;
    RUN;
    ````

- ``DO WHILE``

    ````sas
    DATA mydata;
        sum = 0;
        var = 1
        DO WHILE (var<6);
            sum = sum + var;
            var + 1;  * shortcut to increment of 1
        END;
    RUN;

    PROC PRINT DATA = mydata;
    RUN;
    ````

## Sub-setting

Use ``PROC SQL``

````sas
DATA Employee; 
    INPUT empid name $ salary DEPT $ ; 
    DATALINES;  /* allows to provide data as table*/
    1 Rick 623.3 IT
    2 Dan 515.2 OPS
    3 Mike 611.5 IT
    4 Ryan 729.1 HR 
    5 Gary 843.25 FIN 
    6 Tusar 578.6 IT 
    7 Pranab 632.8 OPS
    8 Rasmi 722.5 FIN 
;
RUN;
````

# Macro

Macros allow to:

- avoid repetitive sections
- create dynamic variables

````sas
%MACRO test(finish);
    %let i = 1;
    %do %while (&i < &finish);
        %let i= %eval(&i + 1);
    %end
%MEND test;

%test(5)

%MEND
````

# File

## Read file

````sas
DATA temp;
    INFILE '/path/file/';
    DLM=",";
    INPUT col1 col2 col3 $ col4 col5 date9.;  /*assuming col3 is of string type and col5 contains date like '24OCT2024'*/
    FORMAT col5 date9.;
RUN;

PROC PRINT DATA = TEMP;
RUN;
````

## Write file

````sas
PROC EXPORT;
    DATA = mydata
    OUTFILE = "path/file/";
    DBMS = csv;
RUN;
````
