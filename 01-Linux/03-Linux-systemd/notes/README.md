# Linux Systemd 🖥️

This is a **comprehensive reference** for systemd, the init system and service manager used in modern Linux distributions.  
It is suitable for **study, practice, and interview preparation**.

---

## 1️⃣ What is init?

- `init` is the **first process** started by the Linux kernel (PID 1).
- Responsible for starting all other processes and setting up the system environment.
- Traditional init systems: SysVinit, Upstart
- Modern Linux distributions mostly use `systemd`.

---

## 2️⃣ What is systemd?

- systemd is a **suite of programs and libraries**, not a single binary.
- Provides a **system and service manager** running as PID 1.
- Starts the rest of the system and manages services, processes, and resources.
- Components include:
  - `systemctl` → service manager
  - `journalctl` → log management
  - `logind` → login/session manager
  - `networkd` → network management
  - Other smaller programs & libraries

---

## 3️⃣ Systemd Units

**Units** are resources managed by systemd.

**Types of units:**

- `service` → background service/daemon
- `socket` → socket activation
- `device` → hardware device
- `mount` → filesystem mounts
- `timer` → scheduled tasks (alternative to cron)
- `target` → group of units
- `path`, `swap`, `automount` … etc.

**Unit files locations:**

- `/lib/systemd/system/`
- `/run/systemd/system/`
- `/etc/systemd/system/`

**Dependencies and ordering:**

- `Requires=` → unit must start for this unit to start
- `After=` → starts after the specified unit
- `Before=` → starts before the specified unit

---

## 4️⃣ systemctl Basics

| Action                    | Command                               | Description               |
| ------------------------- | ------------------------------------- | ------------------------- |
| Show system status        | `systemctl status`                    | Show overall system state |
| List running units        | `systemctl` or `systemctl list-units` |                           |
| List failed units         | `systemctl --failed`                  |                           |
| List installed unit files | `systemctl list-unit-files`           |                           |

**Managing a unit:**

| Action                 | Command                         |
| ---------------------- | ------------------------------- |
| Start a unit           | `systemctl start <unit>`        |
| Stop a unit            | `systemctl stop <unit>`         |
| Restart a unit         | `systemctl restart <unit>`      |
| Reload configuration   | `systemctl reload <unit>`       |
| Reload systemd manager | `systemctl daemon-reload`       |
| Enable at boot         | `systemctl enable <unit>`       |
| Disable at boot        | `systemctl disable <unit>`      |
| Enable now             | `systemctl enable --now <unit>` |

**Check status:**

- `systemctl status <unit>` → running or not
- `systemctl is-enabled <unit>` → enabled at boot?

---

## 5️⃣ Targets (Runlevels)

- `targets` group multiple units, similar to old runlevels.
- Common targets:
  - `multi-user.target` → normal multi-user mode (non-graphical)
  - `graphical.target` → multi-user with GUI
  - `rescue.target` → single-user mode
- Change target temporarily: `systemctl isolate <target>`
- Change target permanently: `systemctl set-default <target>`

---

## 6️⃣ Power Management

| Action                 | Command                            |
| ---------------------- | ---------------------------------- |
| Reboot                 | `systemctl reboot`                 |
| Power off              | `systemctl poweroff`               |
| Suspend                | `systemctl suspend`                |
| Hibernate              | `systemctl hibernate`              |
| Hybrid sleep           | `systemctl hybrid-sleep`           |
| Suspend then hibernate | `systemctl suspend-then-hibernate` |
| Soft reboot            | `systemctl soft-reboot`            |

---

## 7️⃣ Journal & Logs (`journalctl`)

systemd has its own logging system called **the journal**.

**Basic commands:**

- Show all logs: `journalctl`
- Follow logs in real-time: `journalctl -f`
- Show logs since a time: `journalctl --since "20 min ago"`
- Show previous boot logs: `journalctl -b -1`
- Show logs of a unit: `journalctl -u <unit>`
- Show logs for a PID: `journalctl _PID=1234`
- Filter by executable: `journalctl /usr/lib/systemd/systemd`
- Include explanations: `journalctl -x`
- Show kernel logs: `journalctl -k`
- Show only errors: `journalctl -p err..alert`
- Show user service logs: `journalctl --user -u <unit>`

**Notes:**

- Logs are stored in `/var/log/journal/` if persistent storage is enabled.
- Can filter by systemd catalog, units, boot, time, or priority.

---

## 8️⃣ Timers (Cron Alternative)

- Timers are `.timer` units that trigger `.service` units.
- Can schedule tasks based on:
  - Calendar events (`OnCalendar`)
  - Monotonic events (`OnActiveSec`, `OnBootSec`)
- Example: `/etc/systemd/system/backup.timer` triggers `backup.service`
- Reload after timer changes: `systemctl daemon-reload`

---

## 9️⃣ Unit Overrides & Environment Variables

- Edit unit without modifying original: `systemctl edit <unit>`
- Add or override environment variables:

```

[Service]
Environment=VAR=value

```

- Restart unit after changes: `systemctl restart <unit>`
