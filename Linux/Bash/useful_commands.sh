# To know the memory usage on UNIX:
free -m # display all the information in MBs

df -h # disk filename command, with the human readable option (adapt the figures of each filesystem)
du -ch # to see the size of each elements in a given repository 

# SEARCH INSIDE FILES
grep --exclude=\*.{pyc,log} -rl './' -e ".*10\.214\.82\.92.*" # find in the current directory and its subdirectorires all the files containing the string "10.214.82.92" inside a 
grep --include=*.tex -lri monte ./* # find all files containing at least one occurence of "monte" inside it 

# Run process in the background --> use ampersand symbol (&)
vlc > /dev/null 2>&1 &  # >/dev/null 2>&1 means stdout --> /dev/null and stderr --> stdout
jobs -1  # displays the status of all stopped and background jobs in the current session
fg  # bring a process to the foreground
bg  # bring a process to the background
nohup vlc &  # nohup ignore all SIGHUP (hangup) signals, sent when terminal is closed

