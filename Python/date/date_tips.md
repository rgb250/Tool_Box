# Date Tips

## 1. Conversion
```python
import pandas as pd
import datetime as datetime 

# String Formatted Date --> Date
date_standard = datetime.strptime('2023-10-11', format='%Y-%m-%d')

# With time
date_standard = datetime.strptime(
    '2023-10-11 15:11:9,3241654',
    format='%Y-%m-%d %H:%M:%S,%f'  # '%f allows to handle floating seconds'
) 
 
# Date --> IsoWeek
date_isoweek = datetime.strptime('2023-10-11', format='%G%V%u')  # from Python 3.6
date_isoweek = pd.Timestamp.isocalendar(date_standard)

# Date --> String Formatted Date
date_standard.strftime('%A %d %B %Y')  # Wednesday 23 October 2023

# Timestamp --> Iso-Week Date
time_standard_series = time_zone_series.apply(lambda row: datetime.fromisoformat(row))
```

## 2 Formats
Below are the character codes to format the date and time:-

|Symbol| Meaning                                                                                    |
|:----:|:-------------------------------------------------------------------------------------------|
| %d   |Returns the day of the month, from 01 to 31.                                                |
| %u   |Returns the iso-week day of the month, from 01 to 31.                                       |
| %m   |Returns the month of the year, from 01 to 12.                                               |
| %V   |Returns the iso-week month of the year, from 01 to 12.                                      |
| %Y   |Returns the year in four-digit format (Year with century). like, 2021.                      |
| %G   |Returns the iso-week year in four-digit format (Year with century). like, 2021.             |
| %y   |Returns year in two-digit format (year without century). like, 19, 20, 21                   |
| %A   |Returns the full name of the weekday. Like, Monday, Tuesday                                 |
| %a   |Returns the short name of the weekday (First three character.). Like, Mon, Tue              |
| %B   |Returns the full name of the month. Like, June, March                                       |
| %b   |Returns the short name of the month (First three character.). Like, Mar, Jun                |
| %H   |Returns the hour. from 01 to 23.                                                            |
| %I   |Returns the hour in 12-hours format. from 01 to 12.                                         |
| %M   |Returns the minute, from 00 to 59.                                                          |
| %S   |Returns the second, from 00 to 59.                                                          |
| %f   |Return the microseconds from 000000 to 999999                                               |
| %p   |Return time in AM/PM format                                                                 |
| %c   |Returns a locale’s appropriate date and time representation                                 |
| %x   |Returns a locale’s appropriate date representation                                          |
| %X   |Returns a locale’s appropriate time representation                                          |
| %z   |Return the UTC offset in the form ±HHMM[SS[.ffffff]] (empty string if the object is naive). |
| %Z   |Return the Time zone name (empty string if the object is naive).                            |
| %j   |Returns the day of the year from 01 to 366                                                  |
| %w   |Returns weekday as a decimal number, where 0 is Sunday and 6 is Saturday.                   |
| %U   |Returns the week number of the year (Sunday as the first day of the week) from 00 to 53     |
| %W   |Returns the week number of the year (Monday as the first day of the week) from 00 to 53     |

## Change local

For example try to make Python understand the date "*01 JANVIER 2024*":

````python
from datetime import datetime
import locale
locale.setlocale(locale.LC_ALL, 'fr_FR.UTF-8')                           # we will be able to recognize french term

date_standard = datetime.strptime('01 JANVIER 2023', format='%d %B %Y')  # will works perfectly
````