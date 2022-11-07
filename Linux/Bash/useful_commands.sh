# To know the memory usage on UNIX:
free -m # display all the information in MBs

df -h # disk filename command, with the human readable option (adapt the figures of each filesystem)
du -h --max-depth 1 ./folder_path | sort -h # to see the size of each elements in a given repository with a depth of 1 and sorted by size 

# SEARCH INSIDE FILES
grep -n -e 'text_to_search' file1 file2  # allows to display the row number
grep --exclude=\*.{pyc,log} -rl './' -e ".*10\.214\.82\.92.*" # find in the current directory and its subdirectorires all the files containing the string "10.214.82.92" inside a 
grep --include=*.tex -lri monte ./* # find all files containing at least one occurence of "monte" inside it 


# PROCESS
ps aux  # ps aux --> a: process of all users, u: process's users/owner x: process not attached to a terminal 
cat /proc/<PID>/cmdline  # provide the command line that called the process <PID>
# Run process in the background --> use ampersand symbol (&)
vlc > /dev/null 2>&1 &  # >/dev/null 2>&1 means stdout --> /dev/null and stderr --> stdout
jobs -1  # displays the status of all stopped and background jobs in the current session
fg  # bring a process to the foreground
bg  # bring a process to the background
nohup vlc &  # nohup ignore all SIGHUP (hangup) signals, sent when terminal is closed


# KILL
kill -15 <PID> # default behavior of kill command, ask the program kindly to terminate
kill -2 <PID>  # equivalent to Ctrl+C, use it if the above command did not work 
kill -9 <PID>  # use it if the above command did not work
kill -11 <PID>  # use it if the above command did not work, the process will be likely a zombie one
kill -1 1      # restart a process associated with the status "defunct"


EVALUATE
echo $(eval "echo $var") # this produce a string with the value of the variable var