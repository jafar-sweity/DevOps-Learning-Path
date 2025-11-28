# Shell Scripting – Basics Cheat Sheet

## 📌 What is a Shell Script?
A **shell script** is a text file containing Linux commands executed sequentially.  
It is used to:
- **Automate** repetitive tasks
- Ensure **portability** (runs on any Linux distribution)
- Enable **scheduling** (e.g., cron jobs)
- Implement logic and simple automation efficiently

---

## 📌 File Extension
Shell scripts use the `.sh` extension.

---

## 📌 Make Script Executable
After creating a script like `script.sh`, make it executable:

```bash
chmod +x script.sh
````

---

## 📌 Running a Shell Script

1. Using `sh` command:

```bash
sh script.sh
```

2. Running it directly:

```bash
./script.sh
```

---

## 📌 Shebang (#!)

The first line in a script tells Linux which interpreter to use:

```bash
#!/bin/bash
```

Examples:

```bash
#!/usr/bin/env bash
#!/usr/bin/python3
#!/bin/sh
```

---

## 📌 Logical Operators

### AND

```bash
command1 && command2
```

* Second command executes **only if the first succeeds**.

### OR

```bash
command1 || command2
```

* Second command executes **only if the first fails**.

---

## 📌 Exit on Error

```bash
set -e
```

* The script exits immediately if any command returns a non-zero exit code.

---

## 📌 Wildcards & Special Characters

| Symbol | Name / Use                           | Example                | Explanation                                 |
| ------ | ------------------------------------ | ---------------------- | ------------------------------------------- |
| `*`    | Asterisk                             | `ls *.txt`             | Matches zero or more characters             |
| `?`    | Question mark                        | `ls file?.txt`         | Matches exactly one character               |
| `[ ]`  | Character set                        | `ls file[1-3].txt`     | Matches any single character in brackets    |
| `{ }`  | Brace expansion                      | `echo file{1,2,3}.txt` | Generates a list of items                   |
| `~`    | Tilde                                | `cd ~`                 | Represents the home directory               |
| `**`   | Double asterisk (recursive, Bash 4+) | `ls **/*.txt`          | Matches files recursively in subdirectories |
| `$`    | Dollar sign                          | `echo $var`            | Expands the value of a variable             |

---

## 📌 File Test Operators

| Test | Meaning                          |
| ---- | -------------------------------- |
| `-e` | Checks if file exists (any type) |
| `-f` | Checks if it is a regular file   |
| `-d` | Checks if it is a directory      |
| `-r` | Checks if readable               |
| `-w` | Checks if writable               |
| `-x` | Checks if executable             |

Example:

```bash
if [[ -e "$file" ]]; then
    echo "File exists"
fi
```

---

## 📌 Comparison Operators

### Numeric:

* `-eq` → equal
* `-ne` → not equal
* `-lt` → less than
* `-le` → less than or equal
* `-gt` → greater than
* `-ge` → greater than or equal

### String:

* `"a" == "b"` → equal
* `"a" != "b"` → not equal
* `-z "$str"` → string is empty
* `-n "$str"` → string is not empty

---

## 📌 Notes

* Prefer `[[ condition ]]` over `[ condition ]` for more robust checks.
* `test` command is equivalent to `[ ]` but less commonly used today.
* Use `echo $?` to check the exit status of the last command (0 = success, non-zero = failure).
* Use `set -u` to treat unset variables as an error when substituting.
* Use `set -o pipefail` to ensure a pipeline fails if any command fails.