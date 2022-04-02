# To know the memory usage on UNIX:
free -m # display all the information in MBs

df -h # disk filename command, with the human readable option (adapt the figures of each filesystem)
du -ch # to see the size of each elements in a given repository 

grep --exclude=\*.{pyc,log} -rl './' -e ".*10\.214\.82\.92.*" # find in the current directory and its subdirectorires all the files containing the string "10.214.82.92" inside a 
