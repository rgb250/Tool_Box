# Table of Content

## 1) Packages
### a. R location
````r
file.path(R.home('bin'), 'R')
````
### b. Beginning of the script
```r
if(!require(pacman)){        # require return FALSE if the package does not exist
  install.packages('pacman')  # pacman will load, and install if needed, a list of specified packages 
}
pacman::p_load(
  'data.table', 'magrittr', 'ggplot2'
)
```

## 2) Modifying data 
*data.table* objects will be the main used objects.
### a. Basic changes on data frames
To be able to use data.table function to a data frame object:
```r
setDT(df)  # analogous to df <- data.table(df)
```

```r
setnames(data, old=c('column.1', 'column.2'), new=c('c1', 'c2'))
```

### b. Use group
```r
data[, .SD[which.max(sales)], by=department]  # get the maximum value of sales for each department
data[, .N, by=team]  # get the number of rows per team
data[, .(different.size=length(unique(size))), keyby=.(team)]  # unique count of different basketball player sizes by team
```

### c Apply functions
```r
data[, lapply(.SD, mean), .SDcols=c('x1', 'x2')] # get a vector whose components correspond to mean of x1 and x2 features
```

### d. Index 
```r
data[, row.index:=row.names(data)]  # creating a column with index values
data[, c('x2', 'x3'):=NULL]  # removing x2 and x3 columns
```

### e. Sorting
```r
setorder(data, -x2)  # decreasing order of x2 values
data[, ID:=.GRP, keyby=x2]  # sort data by x2, ID:=GRP create a id to each group of values in x2, then keyby by default sort the values
```