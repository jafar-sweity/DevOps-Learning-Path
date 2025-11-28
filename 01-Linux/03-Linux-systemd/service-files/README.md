# Systemd Service Files 📝

This folder explains **systemd service files (`.service`)**, how they work, their structure, and practical examples.

---

## 1️⃣ What is a Service File?

- A **service file** is a configuration file that tells systemd **how to manage a service** (start, stop, restart, dependencies, etc.).
- Usually ends with `.service` (e.g., `nginx.service`).
- Located in:
  - `/lib/systemd/system/` → default system services
  - `/etc/systemd/system/` → custom/overridden services
  - `/run/systemd/system/` → runtime units (temporary)

- When system boots, systemd reads service files to know **what services to start and how**.

---

## 2️⃣ Basic Structure of a `.service` File

A typical service file has **three main sections**:

```ini
[Unit]
Description=My Example Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/myprogram
Restart=on-failure

[Install]
WantedBy=multi-user.target
````

### **Sections Explained**

### `[Unit]`

* Metadata about the service.
* Common directives:

  * `Description=` → short description
  * `After=` → start this service **after** another target/service
  * `Requires=` → service must start; otherwise fail
  * `Wants=` → optional dependency

### `[Service]`

* Main configuration of the service behavior.
* Common directives:

  * `Type=` → how systemd determines if service is running

    * `simple` → default, service started directly with `ExecStart`
    * `forking` → for daemons that fork to background
    * `oneshot` → service runs once and exits
    * `notify` → service sends ready signal
    * `idle` → start after other jobs
  * `ExecStart=` → command to start the service
  * `ExecStop=` → command to stop service (optional)
  * `Restart=` → when to restart (`no`, `on-failure`, `always`, `on-abort`)
  * `User=` → run as a specific user
  * `WorkingDirectory=` → set working dir for the service
  * `Environment=` → set environment variables

### `[Install]`

* Installation info for enabling/disabling service.
* Common directives:

  * `WantedBy=` → target that should start this service (`multi-user.target` is common for normal services)
  * `Alias=` → alternative name for service

---

## 3️⃣ Example: Custom Service

Create a service to run a script `/usr/local/bin/myscript.sh`:

1. Create the service file:

```bash
sudo nano /etc/systemd/system/myscript.service
```

2. Paste content:

```ini
[Unit]
Description=My Custom Script Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/myscript.sh
Restart=on-failure
User=jafar
WorkingDirectory=/home/jafar

[Install]
WantedBy=multi-user.target
```

3. Enable and start:

```bash
sudo systemctl daemon-reload          # reload systemd after creating/editing service
sudo systemctl enable myscript        # enable at boot
sudo systemctl start myscript         # start now
sudo systemctl status myscript        # check status
```

---

## 4️⃣ Checking & Managing Services

| Action               | Command                            |
| -------------------- | ---------------------------------- |
| Start a service      | `sudo systemctl start <service>`   |
| Stop a service       | `sudo systemctl stop <service>`    |
| Restart a service    | `sudo systemctl restart <service>` |
| Reload configuration | `sudo systemctl daemon-reload`     |
| Enable at boot       | `sudo systemctl enable <service>`  |
| Disable at boot      | `sudo systemctl disable <service>` |
| Check status         | `sudo systemctl status <service>`  |
| Show logs            | `journalctl -u <service>`          |

---

## 5️⃣ Useful Tips

* Always run `sudo systemctl daemon-reload` after **creating or editing** a service.
* Use `Type=forking` for services that **daemonize themselves**.
* Use `Restart=on-failure` for critical services to **auto-recover**.
* Group services with `WantedBy=` in `[Install]` to integrate with boot targets.
* Logs are available via `journalctl -u <service>` for troubleshooting.
