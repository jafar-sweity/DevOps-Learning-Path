# User, Group, & Permissions Management

| Command | Description                                 | Example Usage                  | Notes                     |
| ------- | ------------------------------------------- | ------------------------------ | ------------------------- |
| chmod   | Changes file permissions                    | chmod 755 script.sh            | 7=rwx, 5=rx               |
| chown   | Changes file ownership                      | sudo chown user:group file.txt |                           |
| su      | Switches user identity                      | su - root                      |                           |
| sudo    | Executes a command with elevated privileges | sudo apt update                |                           |
| useradd | Creates a new user account                  | sudo useradd -m newuser        | -m creates home directory |
