# Shell Scripting Scripts 🛠️

This folder contains **10 ready-to-use shell scripts** that cover exercises from the Shell Scripting module.  
Each script demonstrates a practical concept, from basics to more advanced tasks.

---

## Scripts List

### 1️⃣ 01-even-odd.sh
- Ask the user for a number
- Print whether the number is **Even** or **Odd**
- Concepts: arithmetic, conditionals, input

### 2️⃣ 02-file-exists.sh
- Ask the user for a filename
- Print `File exists` if it exists, `File not found` if it doesn’t
- Concepts: file testing, conditionals, input

### 3️⃣ 03-calculator.sh
- Ask for two numbers and an operator (+, -, *, /)
- Calculate and print the result
- Concepts: arithmetic, case statements, input validation

### 4️⃣ 04-loop-files.sh
- Print all filenames in the current directory using a **for loop**
- Concepts: loops, variable expansion, directory listing

### 5️⃣ 05-backup.sh
- Create a folder named `backup` if it doesn’t exist
- Copy all `.txt` files into the `backup` folder
- Concepts: directories, file copying, automation

### 6️⃣ 06-ping-checker.sh
- Ask for a domain name
- Ping the domain once
- Print `Online` if ping succeeds, `Offline` if it fails
- Concepts: commands, exit codes, conditionals

### 7️⃣ 07-sum-numbers.sh
- Take a list of numbers from the user
- Sum them and print the total
- Concepts: arrays, loops, arithmetic

### 8️⃣ 08-count-lines.sh
- Count the number of lines in each `.txt` file
- Print result like:
```

file1.txt : 12 lines
file2.txt : 8 lines

````
- Concepts: loops, command substitution, file handling

### 9️⃣ 09-positional-parameters.sh
- Use positional parameters in a script:
```bash
./09-positional-parameters.sh name age country
````

* Output:

```
Your name is: ...
Your age is: ...
Your country is: ...
```

* Concepts: arguments, parameter handling

### 🔟 10-menu.sh

* Interactive menu script:

```
1) Show date
2) Show current directory files
3) Show disk usage
4) Exit
```

* Execute the command based on user selection
* Concepts: loops, case statements, user input, automation

---

## ✅ How to Use

1. Make scripts executable (if not already):

```bash
chmod +x *.sh
```

2. Run any script:

```bash
./01-even-odd.sh
```

3. Modify and experiment to practice concepts

---

