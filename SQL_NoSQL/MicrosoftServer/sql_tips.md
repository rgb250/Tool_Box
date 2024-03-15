- [I) Table operations](#i-table-operations)
  - [1) Creation of table](#1-creation-of-table)
  - [2) List of all the tables](#2-list-of-all-the-tables)
  - [3) List of columns from table](#3-list-of-columns-from-table)
- [II) Operations on columns](#ii-operations-on-columns)
  - [1) Change of types](#1-change-of-types)
  - [2) Search](#2-search)
  - [3) Function](#3-function)
  - [4) Aggregation functions](#4-aggregation-functions)
- [III) Specifities](#iii-specifities)
  - [1) Deal with special name columns](#1-deal-with-special-name-columns)
- [IV) Join](#iv-join)
  - [1) Filter table before applying a join](#1-filter-table-before-applying-a-join)


# I) Table operations
## 1) Creation of table
````sql
IF NOT EXISTS (
	SELECT * FROM sysobjects WHERE name='cars' and xtype='U')
    CREATE TABLE table(
       name varchar(64) not null
	…
    )
GO
````
## 2) List of all the tables
````sql
SELECT TABLE_CATALOG, TABLE_SCHEMA, TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES t 
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_SCHEMA, TABLE_NAME
````

## 3) List of columns from table
````sql
SELECT COLUMN_NAME 
FROM INFORMATION_SCHEMA.COLUMNS c 
WHERE TABLE_NAME = 'table_name' AND TABLE_SCHEMA = 'schema_name'
ORDER BY COLUMN_NAME;
````

# II) Operations on columns
## 1) Change of types
````sql
CONVERT(DATE, str_date_column)
````

## 2) Search
````sql
WHERE str_col LIKE '%[a-zA-Z]%'
````

## 3) Function
````sql
CASE(yn_col_name WHEN 'Y' THEN 1 ELSE 0 END)
````

## 4) Aggregation functions
````sql
COUNT(*)
````

# III) Specifities
## 1) Deal with special name columns
`[]` to use special column name like `date`, `month`

# IV) Join
## 1) Filter table before applying a join
````sql
SELECT c.Customer, c.State, e.Entry
FROM Customer c
LEFT JOIN Entry (SELECT * FROM Employee WHERE Category='D') AS e -- filter step
   ON c.Customer=e.Customer
````
