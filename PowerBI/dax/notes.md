- [In a few words](#in-a-few-words)
- [Script](#script)
  - [Basic](#basic)
- [Calculations](#calculations)
  - [Measures](#measures)
  - [Columns](#columns)
- [Queries](#queries)
  - [Keywords](#keywords)
    - [EVALUATE](#evaluate)
    - [ORDER BY and START AT](#order-by-and-start-at)
    - [DEFINE](#define)
- [Variables](#variables)
- [Context](#context)

# In a few words

``DAX`` is primarily a formula language, typically what we do in Exel when using formula, and it
is also a query language meaning that it can be used to retrieve data in databases.


# Script

## Basic

````sql
DEFINE
 MEASURE DimProduct[Selected Color] = SELECTEDVALUE(DimProduct[Color], "No Single Selection")
EVALUATE
 SUMMARIZECOLUMNS  
   (ROLLUPADDISSUBTOTAL(DimProduct[Color], "Is Total"),  
   "Selected Color", [Selected Color])ORDER BY [Is Total] ASC,  
   [Color] ASC
````

# Calculations

## Measures

They are ``dynamic calculation formulas``  where the result changes depending on the context.

## Columns

They are columns that we add to an existing table and then create a DAX formula.

# Queries

## Keywords

There is one required keyword ``EVALUATE`` and other optional ones: *ORDER BY*, *START AT*,
*DEFINE*, *MEASURE*, *VAR*, *TABLE*, and *COLUMN*

### EVALUATE

A DAX query is an ``EVALUATE`` statement containing a table expression.\
At least one EVALUATE statement is required however a query can contain any number of EVALUATE

````dax
EVALUATE 
  <table> /* <table> corresponds to a table expression */
````

### ORDER BY and START AT

````dax
EVALUATE 
  'Internet Sales'
ORDER BY
  'Internet Sales'[Sales Order Number] /* The order to follow to range values of 'Internet Sales'*/
START AT "S07000"                       /* The value from which Sales Order Number must start at */
````

### DEFINE

It allows to introduce one or more calculated entity definition that exist only for the
duration of the query.\
What DEFINE contains is valid for all EVALUATE statements, the syntax is the following one:

````dax

DEFINE
  MEASURE 'Internet Sales'[Sales Sum] = SUM('Internet Sales'[Sales Value])
  VAR  SalesReference = 150
  TABLE <table name> = <table expression>
  COLUMN <table name>[<column name>] = <scalar expression>

EVALUATE
  <table expression>

````


# Variables

# Context