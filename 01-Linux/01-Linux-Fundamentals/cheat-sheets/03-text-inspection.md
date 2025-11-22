# Text Filtering & File Inspection

| Command | Description | Example Usage | Notes |
|---------|-------------|---------------|-------|
| cat     | Concatenates files and prints content | cat /etc/hosts |  |
| grep    | Searches for lines matching a pattern | grep 'keyword' file.txt | Often used with the pipe (|) |
| head    | Displays the beginning of a file | head -n 5 logfile.log | Default 10 lines |
| tail    | Displays the end of a file | tail -f logfile.log | -f follows output in real-time |
| less    | Displays file content page-by-page | less bigfile.txt | Allows scrolling |
| wc      | Prints word, line, byte counts | wc -l file.txt | -l counts lines |
| cut     | Removes sections/columns from each line | cut -d: -f1 /etc/passwd | -d sets delimiter; -f specifies field |
