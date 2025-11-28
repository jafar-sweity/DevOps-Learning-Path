# Shell Scripting Exercises 📝

This folder contains **practical exercises** for practicing Shell Scripting concepts.  
Each exercise reinforces topics from the cheat sheets (basics, variables, loops, conditionals, functions, and advanced scripting).

---

## Exercises List

### 1️⃣ Exercise 1 — Even/Odd (Warm Up)

- Ask the user for a number
- Print whether the number is **Even** or **Odd**

### 2️⃣ Exercise 2 — Check if File Exists

- Ask the user for a filename
- Print `File exists` if it exists
- Print `File not found` if it doesn’t exist

### 3️⃣ Exercise 3 — Simple Calculator

- Ask for two numbers and an operator (+, -, \*, /)
- Perform the calculation and print the result

### 4️⃣ Exercise 4 — Loop Through Files

- Print all filenames in the current directory using a **for loop**

### 5️⃣ Exercise 5 — Backup Script

- Create a folder named `backup` if it doesn’t exist
- Copy all `.txt` files into the `backup` folder

### 6️⃣ Exercise 6 — Ping Checker

- Ask for a domain name
- Run `ping -c 1`
- Print `Online` if ping succeeds, `Offline` if it fails

### 7️⃣ Exercise 7 — Sum of Numbers

- Ask the user for a list of numbers
- Sum them and print the total

### 8️⃣ Exercise 8 — Count Lines in Each File

- Count number of lines in each `.txt` file
- Print result in format:

```

file1.txt : 12 lines
file2.txt : 8 lines

```

### 9️⃣ Exercise 9 — Positional Parameters

- Use positional parameters:

```bash
./script.sh name age country
```

- Output:

```
Your name is: ...
Your age is: ...
Your country is: ...
```

### 🔟 Exercise 10 — Menu Program

- Create a menu script:

```
1) Show date
2) Show current directory files
3) Show disk usage
4) Exit
```

- Execute the command based on user selection
