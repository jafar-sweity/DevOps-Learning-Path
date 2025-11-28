# Projects Folder

This folder contains small practical projects to practice **Linux commands, shell scripting, and system management**.  
Each project has its own folder with scripts, notes, or supporting files.

---

## Projects Navigation

### 1️⃣ Docker Checker

**Folder:** `Docker-Checker/`  
**Goal:** Check if Docker is installed and running, and display active containers.  
**Features:**

- Verifies if `docker` command exists.
- Checks if Docker service is active.
- Shows running containers (`docker ps`).
- Suggests how to start Docker if stopped.
- Includes systemd service and timer units for automatic checks.  
  **Why it’s useful:** Realistic DevOps project to practice commands, conditional checks, and system status monitoring.

---

### 2️⃣ System Update Checker

**Folder:** `System-Update-Checker/`  
**Goal:** Check if your system is up-to-date.  
**Features:**

- Runs `apt update`.
- Checks if any packages can be upgraded (`apt list --upgradable`).
- Prints list of upgradable packages.
- Can prompt the user to run `apt upgrade`.  
  **Why it’s useful:** Learn interacting with package manager, parsing command output, and user input.

---

### 3️⃣ Backup Script

**Folder:** `Backup-Script/`  
**Goal:** Automatically backup important files.  
**Features:**

- Asks for source and destination folders.
- Copies files with timestamp.
- Logs backup results.  
  **Why it’s useful:** Learn file operations, variables, date commands, and logging.

---

### 4️⃣ Server Health Monitor

**Folder:** `Server-Health-Monitor/`  
**Goal:** Monitor server performance (CPU, memory, disk) and critical services.  
**Features:**

- Display CPU, Memory, Disk usage.
- Check important services (nginx, mysql, etc.).
- Send alerts if usage exceeds thresholds.
- Includes systemd service and timer units for automated monitoring.  
  **Why it’s useful:** Practice loops, conditionals, system commands, and server monitoring.

---

### 5️⃣ Website Availability Checker

**Folder:** `Website-Availability-Checker/`  
**Goal:** Check if websites or servers are online.  
**Features:**

- Accept a list of URLs from user or file.
- Ping or curl to check status.
- Print Online / Offline status.
- Log results to a file.  
  **Why it’s useful:** Learn networking commands, file reading, loops, and output formatting.

---

**Tip:** Use this README to quickly navigate between projects and see their goals, features, scripts, and learning outcomes.
