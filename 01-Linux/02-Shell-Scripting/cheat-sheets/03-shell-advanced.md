# Shell Scripting – Advanced Concepts

This cheat sheet covers **arrays, string manipulation, scheduling, error handling, and other advanced shell scripting concepts**.  
Perfect for interviews and deepening your DevOps skillset.

---

## 📌 Arrays in Shell

### Declare an Array

```bash
fruits=("apple" "banana" "cherry")
```

### Access Array Elements

```bash
echo ${fruits[0]}   # apple
echo ${fruits[1]}   # banana
```

### Array Length

```bash
echo ${#fruits[@]}  # total number of elements
```

### Loop Through Array

```bash
for fruit in "${fruits[@]}"; do
    echo "Fruit: $fruit"
done
```

### Add Elements

```bash
fruits+=("orange")
```

### Remove Elements

```bash
unset fruits[1]  # removes "banana"
```

---

## 📌 String Manipulation

### Substring Extraction

```bash
str="HelloWorld"
echo ${str:0:5}  # Hello
```

### String Length

```bash
echo ${#str}  # 10
```

### Replace Substring

```bash
echo ${str/World/Everyone}  # HelloEveryone
```

### Check if String is Empty

```bash
if [[ -z "$str" ]]; then
    echo "String is empty"
fi
```

---

## 📌 Command Substitution

Capture command output in a variable:

```bash
current_date=$(date)
echo "Today is $current_date"
```

---

## 📌 Scheduling Scripts with cron

### Edit cron jobs

```bash
crontab -e
```

### Cron Syntax

```
*     *     *     *     *  command to execute
-     -     -     -     -
|     |     |     |     |
|     |     |     |     +---- Day of week (0-7) (Sunday=0 or 7)
|     |     |     +---------- Month (1-12)
|     |     +---------------- Day of month (1-31)
|     +---------------------- Hour (0-23)
+---------------------------- Minute (0-59)
```

### Example

Run a backup script every day at 2:30 AM:

```bash
30 2 * * * /home/jafar/backup.sh
```

---

## 📌 Error Handling

### Exit on Error

```bash
set -e
```

### Check Command Status

```bash
mkdir /tmp/testdir
if [[ $? -eq 0 ]]; then
    echo "Directory created successfully"
else
    echo "Failed to create directory"
fi
```

### Trap Errors

```bash
trap 'echo "Error occurred at line $LINENO"' ERR
```

---

## 📌 Redirecting Output

### Standard Output (stdout)

```bash
echo "Hello" > file.txt   # overwrite
echo "World" >> file.txt  # append
```

### Standard Error (stderr)

```bash
ls /nonexistent 2> error.log
```

### Redirect Both stdout and stderr

```bash
command &> all_output.log
```

---

## 📌 Background Processes

Run a command in the background:

```bash
./long_script.sh &
```

Check background jobs:

```bash
jobs
```

Bring job to foreground:

```bash
fg %1
```

Kill a process:

```bash
kill PID
```

---

## 📌 Useful Built-in Variables

| Variable | Meaning                           |
| -------- | --------------------------------- |
| `$0`     | Script name                       |
| `$1,$2…` | Positional parameters             |
| `$#`     | Number of arguments               |
| `$@`     | All arguments (as separate words) |
| `$*`     | All arguments (as single string)  |
| `$?`     | Exit status of last command       |
| `$$`     | PID of current script             |
| `$!`     | PID of last background command    |

---

## 📌 Best Practices (Advanced)

1. Always quote variables: `"$var"`
2. Use `set -e` to stop on errors
3. Use `trap` to handle unexpected errors
4. Modularize scripts using functions
5. Test scripts in multiple environments for portability
6. Use comments generously
7. Validate user input before processing

---

## 📌 Full Example – Advanced Script

```bash
#!/bin/bash
set -e
trap 'echo "Error occurred at line $LINENO"' ERR

# Array of directories to backup
dirs=("/etc" "/home/jafar" "/var/log")
backup_dir="/tmp/backup"

mkdir -p "$backup_dir"

for dir in "${dirs[@]}"; do
    tar -czf "$backup_dir/$(basename $dir).tar.gz" "$dir"
    echo "Backed up $dir"
done

echo "Backup completed successfully!"
```

This script demonstrates:

- Arrays
- Loops
- Functions (if added)
- Error handling with `trap` and `set -e`
- Output redirection
- Portable, production-ready scripting
