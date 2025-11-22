# Process & Service Management

| Command              | Description                           | Example Usage              | Notes                                       |
| -------------------- | ------------------------------------- | -------------------------- | ------------------------------------------- |
| ps                   | Reports snapshot of current processes | ps -elf                    | -e (all), -f (full format)                  |
| top                  | Real-time dynamic view of processes   | top                        |                                             |
| systemctl status     | Status of a systemd service           | systemctl status sshd      | Standard tool for modern service management |
| systemctl start/stop | Controls service state                | sudo systemctl start nginx |                                             |
| kill                 | Sends signal to a process             | kill -9 1234               | -9 sends SIGKILL (force)                    |
