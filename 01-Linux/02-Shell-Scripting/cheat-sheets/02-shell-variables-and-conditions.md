# Shell Scripting – Variables, Loops, Functions, and Input/Output

This cheat sheet covers everything you need to know about **variables, positional parameters, conditional statements, loops, functions, and reading input in shell scripts**.  
It is detailed enough for revision or technical interviews.

---

## 📌 Variables in Shell Scripting

### Declaration

- **Integer variable**

```bash
declare -i num=10
```

- **String variable**

```bash
name="Jafar"
# or
declare s="Jafar"
```

- **Constant (readonly variable)**

```bash
declare -r PI=3.14
```

### Rules

- No spaces around `=` in assignment
- Case sensitive (`VAR` ≠ `var`)
- Use `$` to access value:

```bash
echo $name
```

---

## 📌 Positional Parameters (Arguments Passed to Scripts)

Shell scripts can accept arguments from the command line. Special variables:

| Variable    | Meaning                              |
| ----------- | ------------------------------------ |
| `$0`        | Script name                          |
| `$1,$2,...` | First, second, third… argument       |
| `$#`        | Number of arguments passed           |
| `$@`        | All arguments as separate words      |
| `$*`        | All arguments as a single string     |
| `$?`        | Exit status of last executed command |
| `$$`        | PID of current script                |
| `$!`        | PID of last background command       |

### Example

```bash
#!/bin/bash
echo "Script name: $0"
echo "First argument: $1"
echo "Second argument: $2"
echo "Total arguments: $#"
```

---

## 📌 Conditional Statements

### `if` Statement

Syntax:

```bash
if [ condition ]; then
    # commands
elif [ condition ]; then
    # commands
else
    # commands
fi
```

### Example – Check if Number is Even or Odd

```bash
#!/bin/bash
echo "Enter a number:"
read i

if (( i % 2 == 0 )); then
    echo "$i is even"
else
    echo "$i is odd"
fi
```

### File Existence Checks

```bash
if [[ -e "$file_name" ]]; then
    echo "File exists"
fi

# -e : any file type
# -f : regular file
# -d : directory
```

---

## 📌 Logical Operators in Conditions

| Operator | Meaning                 |     |             |
| -------- | ----------------------- | --- | ----------- |
| `&&`     | AND (both must be true) |     |             |
| `        |                         | `   | OR (either) |
| `!`      | NOT                     |     |             |

**Example**

```bash
if [[ -f "$file" && -r "$file" ]]; then
    echo "File exists and is readable"
fi
```

---

## 📌 Loops in Shell Scripting

### 1. `for` Loop

Iterates over a list or array.

```bash
#!/bin/bash
for i in 1 2 3 4 5; do
    echo "Number: $i"
done
```

### 2. Loop Over an Array

```bash
arr=("apple" "banana" "cherry")
for fruit in "${arr[@]}"; do
    echo "Fruit: $fruit"
done
```

### 3. `while` Loop

Executes as long as a condition is true.

```bash
count=1
while [ $count -le 5 ]; do
    echo "Count: $count"
    ((count++))
done
```

### 4. `until` Loop

Executes until a condition becomes true.

```bash
count=1
until [ $count -gt 5 ]; do
    echo "Count: $count"
    ((count++))
done
```

---

## 📌 Functions in Shell

### Declaration

```bash
my_function() {
    # logic
    echo "Hello from function"
}
```

### Calling a Function

```bash
my_function
```

### Function with Parameters

```bash
greet() {
    local name=$1
    echo "Hello, $name"
}

greet "Jafar"
```

### Notes

- Functions improve **code reusability** and **modularity**
- Use `local` keyword to limit variable scope to the function

---

## 📌 Reading Input from STDIN

Ask the user for input and store it in a variable:

```bash
#!/bin/bash
echo "Enter your name:"
read name
echo "Hello, $name"
```

### Reading Silent Input (Password)

```bash
read -s -p "Enter password: " password
echo
echo "Password length: ${#password}"
```

### Reading Multiple Inputs

```bash
read -p "Enter first and last name: " first last
echo "Hello $first $last"
```

---

## 📌 Best Practices

1. **Use quotes around variables** to prevent word splitting:

```bash
echo "$var"
```

2. **Use `[[ ]]` instead of `[ ]`** for conditions:

- Supports `&&`, `||`
- More robust for strings with spaces

3. **Use `set -e`** to stop execution on errors

4. **Use comments liberally**:

```bash
# This script prints numbers 1 to 5
for i in {1..5}; do
    echo $i
done
```

5. **Use functions** for repeated tasks

6. **Always test scripts on multiple environments** to ensure portability

---

## 📌 Example Script Combining Everything

```bash
#!/bin/bash
# Script to greet user and check file

read -p "Enter your name: " name
echo "Hello, $name!"

read -p "Enter a file name: " file

if [[ -f "$file" ]]; then
    echo "File exists."
else
    echo "File does not exist."
fi

for i in {1..3}; do
    echo "Loop iteration $i"
done

my_function() {
    echo "This is a function"
}
my_function
```

This script demonstrates:

- Reading input
- Conditional checks
- Loops
- Functions
- Reusability and best practices
