- [Basics](#basics)
  - [Syntax](#syntax)
  - [Special cases](#special-cases)
  - [Variables](#variables)
  - [Strings](#strings)
  - [Array](#array)
  - [Loop](#loop)
  - [Sub-setting](#sub-setting)
- [Macro](#macro)
- [File](#file)
  - [Read file](#read-file)
  - [Import and Export data](#import-and-export-data)
  - [PROC SQL](#proc-sql)
    - [Concatenate](#concatenate)
    - [Converting](#converting)
  - [Macro to zip file](#macro-to-zip-file)

# Basics

## Syntax

Some general rules:

- all statement end by ``RUN`` and always with a ``;``
- the keyword ``DATA`` allows to create temporary dataset
- local variable are declared with ``%let``
- inside a macro we must use a variable \<var> like this ``&var.``

## Special cases

- When column headers contain special characters:
    ````sas
    PROC SQL;
        SELECT 
            'spécial name'n 
        FROM table
    QUIT;
    ````

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

- Defini²ng an array

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
            var + 1;  /* shortcut to increment of 1 */
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
    DATALINES;  /* allows to provide data as table */
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

````sas
%LET LISTE_ETAB_RCE;
PROC SQL;
		SELECT
			CIB INTO: LISTE_ETAB_RCE SEPARATED BY '|'			
		FROM DATA_COM.ETAB_BPCE
		WHERE SI = 'VECEP'
			AND 'Réseau'n = 'RESEAU CE'
			AND 'libelle court'n LIKE 'CAISSE %'
		ORDER BY CIB;
QUIT;
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

## Import and Export data

````sas
PROC IMPORT
    DATAFILE="/sasprod/etude/IGG/rgbenou/prdt_epargne_bpce_202409_suspicious.csv"
    OUT=gbenou.prdt_epargne_bpce_202409_susp
    DBMS=CSV
    REPLACE;
    DELIMITER=";";
RUN;

````

````sas
PROC EXPORT
    DATA=mydata
    OUTFILE="path/file/"
    DBMS=XLSX;
RUN;
````


## PROC SQL

### Concatenate

````sas
%MACRO CONCAT_TABLES(LISTE_ETAB, NOM_TABLE_FINALE);
	%LOCAL i TABLE QUERY;
	%DO i=1 %TO %SYSFUNC(COUNTW(&LISTE_ETAB, '|'));
		%LET TABLE = %SCAN(&LISTE_ETAB, &i, '|');
		%IF &i = 1 
			%THEN %DO;
				%LET QUERY = SELECT * FROM gbenou.PRDT_EPARGNE_202409_&TABLE.;
			%END;
		%ELSE
			%DO;
				%LET QUERY = &QUERY UNION SELECT * FROM gbenou.PRDT_EPARGNE_202409_&TABLE.;
				%PUT NOTE: Appended table based on &=TABLE;	
			%END;
	%END;
	PROC SQL;
		CREATE TABLE &NOM_TABLE_FINALE. AS (
			&QUERY
		);
	QUIT;
%MEND CONCAT_TABLES;
%CONCAT_TABLES(LISTE_ETAB=&LISTE_ETAB_RCE, NOM_TABLE_FINALE=PRDT_EPARGNE_202409_RCE);
````

````sas
%MACRO CONCAT_TABLES(LISTE_PERD_ARRT_INFO);
	%DO i=1 %TO %SYSFUNC(COUNTW(&LISTE_PERD_ARRT_INFO, '|'));
		%LET PERD_ARRT_INFO = %SCAN(&LISTE_PERD_ARRT_INFO, &i, '|');
		%LET TABLE = iCE_COMM_PRDT_EPARGNE_&PERD_ARRT_INFO.;
		%QUERY_TABLE(&PERD_ARRT_INFO);
		%IF &i = 1 
			%THEN %DO;
				%LET QUERY = SELECT * FROM &TABLE.;
			%END;
		%ELSE
			%DO;
				%LET QUERY = &QUERY UNION SELECT * FROM &TABLE.;
			%END;
		
		%PUT NOTE: Appended table based on &=TABLE;	
	%END;
	PROC SQL;
		CREATE TABLE gbenou.iCE_COMM_PRDT_EPARGNE AS (
			&QUERY
		);
	QUIT;
	%DO i=1 %TO %SYSFUNC(COUNTW(&LISTE_PERD_ARRT_INFO, '|'));
		%LET PERD_ARRT_INFO = %SCAN(&LISTE_PERD_ARRT_INFO, &i, '|');
		%LET TABLE = iCE_COMM_PRDT_EPARGNE_&PERD_ARRT_INFO.;
		PROC SQL;
			DROP TABLE &TABLE.;
		QUIT;
	%END;
%MEND CONCAT_TABLES;
````

### Converting

`````sas
PROC SQL;
    SELECT
        var_any,
        var_str,
        var_num,
        INPUT(var_str, datetime.) AS var_str_to_date,
        PUT(var_num, best32.) AS var_num_to_str
    FROM table_any
QUIT;
`````
For the format check: 
- [date](https://documentation.sas.com/doc/en/vdmmlcdc/8.1/ds2pg/p0bz5detpfj01qn1kz2in7xymkdl.htm)
- [other format](https://documentation.sas.com/doc/en/pgmsascdc/9.4_3.5/leforinforref/n0p2fmevfgj470n17h4k9f27qjag.htm#n1hmvzswkq6fr1n15ke7j0h943v0)

## Macro to zip file

````sas
%MACRO FCT_ZIP(PATH_FILE=, NAME_FILE_ZIP=, PATH_FOLDER_ZIP=);
	%IF %SYSFUNC(FILEEXIST(&PATH_FILE.)) %THEN 
		%DO;
			ODS PACKAGE OPEN NOPF;  /* open file without producing any printed output (nopf)*/
				FILENAME CONCAT "&PATH_FILE.";
			ODS PACKAGE ADD FILE=CONCAT; /* add <FILE_TO_ZIP> to the ODS package and specify the output folder*/
			ODS PACKAGE PUBLISH ARCHIVE PROPERTIES
				(ARCHIVE_PATH="&PATH_FOLDER_ZIP." ARCHIVE_NAME="&NAME_FILE_ZIP.");
			ODS PACKAGE CLOSE;
			FILENAME CONCAT CLEAR;
			%PUT NOTE: Successfully created the zip file "&NAME_FILE_ZIP." IN "&PATH_FOLDER_ZIP.";
		%END;
	%ELSE
		%DO;
			%PUT ERROR: The file &PATH_FILE. does not exist;
		%END;
%MEND FCT_ZIP;
````
