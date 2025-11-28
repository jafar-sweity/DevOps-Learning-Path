# Docker Checker (systemd + Shell)

## Table of Contents

* [Overview](#overview)
* [Learning Goals](#learning-goals)
* [Requirements / Tasks](#requirements--tasks)
* [Systemd Units & Security](#systemd-units--security)
* [How to Test](#how-to-test)
* [Solution / Implementation](#solution--implementation)

---

## Overview

Docker Checker is a shell script that verifies if Docker is installed and running, lists active containers, and attempts to restart the Docker service if it is stopped.
A **systemd timer** schedules periodic checks automatically.

---

## Learning Goals

* Check service status using systemctl
* Work with external commands (docker) and validate availability
* Write human-readable logs and handle exit codes properly
* Create and enable systemd service and timer units

---

## Requirements / Tasks

The script must:

* Check whether the docker command exists
* Check the current state of docker.service (is-active, is-failed)
* List running containers (name, image, status) in a readable table
* Attempt systemctl start docker if the service is stopped
* Write logs to /var/log/docker-checker.log
* Return exit codes:

  * 0 → OK
  * 1 → Recovered with warnings
  * 2 → Failed

---

## Systemd Units & Security

* Service Unit: docker-checker.service (Type=oneshot)
* Timer Unit: docker-checker.timer (e.g., run every 5 minutes)
* User: root required to control Docker service and manage groups
* Security considerations: future improvements could run the script as a non-root user with limited capabilities

---

## How to Test

1. Run the script manually:
   sudo /usr/local/bin/docker-checker.sh

2. Check logs:
   cat /var/log/docker-checker.log

3. Start service manually:
   sudo systemctl start docker-checker.service

4. Enable and start the timer:
   sudo systemctl enable --now docker-checker.timer

5. View recent service logs:
   journalctl -u docker-checker.service -n 200

---

## Solution / Implementation

### 1. Docker Checker Script

Script created initially at `~/Desktop/Projects/docker-checker.sh` and tested manually.
Moved to permanent location: `/usr/local/bin/docker-checker.sh`.

``` sh
#!/bin/bash
set -euo pipefail

LOG_FILE="/var/log/docker-installer.log"
TARGET_USER="${SUDO_USER:-$USER}"

log() {
echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

if [ ! -w "$LOG_FILE" ] 2>/dev/null; then
sudo mkdir -p "$(dirname "$LOG_FILE")"
sudo touch "$LOG_FILE"
sudo chown "$USER":"$USER" "$LOG_FILE" 2>/dev/null || true
fi

log "==== Docker installer/check started by '$TARGET_USER' ===="

if command -v docker &> /dev/null; then
log "Docker binary found: $(command -v docker)"
else
log "Docker not found. Installing Docker..."

sudo apt-get update -y
sudo apt-get install -y ca-certificates curl gnupg lsb-release

sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL [https://download.docker.com/linux/ubuntu/gpg](https://download.docker.com/linux/ubuntu/gpg) -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

ARCH="$(dpkg --print-architecture)"
CODENAME="$(lsb_release -cs)"

echo "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.gpg] [https://download.docker.com/linux/ubuntu](https://download.docker.com/linux/ubuntu) ${CODENAME} stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

log "Docker packages installed."
fi

log "Checking Docker service status..."
if systemctl is-active --quiet docker; then
log "Docker service is already running."
else
log "Docker service is NOT running. Starting..."
if sudo systemctl start docker; then
log "Docker started successfully."
else
log "Failed to start Docker."
fi
fi

sudo systemctl enable docker >/dev/null 2>&1 || true

if [ "$TARGET_USER" != "root" ]; then
sudo usermod -aG docker "$TARGET_USER" || true
log "User '$TARGET_USER' added to docker group."
fi

log "Testing 'docker ps'..."
if docker ps &>/dev/null; then
log "'docker ps' succeeded."
else
log "'docker ps' failed. Trying with sudo..."
if sudo docker ps &>/dev/null; then
log "'sudo docker ps' succeeded."
else
log "'sudo docker ps' failed."
fi
fi

log "Listing running containers:"
TABLE="$(docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}" || true)"
[ -z "$TABLE" ] && log "No running containers." || echo "$TABLE" | tee -a "$LOG_FILE"

log "==== Docker installer/check finished ===="
```

---

### 2. Systemd Service Unit
```bash
Created `docker-checker.service`:

[Unit]
Description=Docker Checker Service
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/docker-checker.sh
RemainAfterExit=no
User=root

[Install]
WantedBy=multi-user.target
```
---
```bash
### 3. Systemd Timer Unit

Created `docker-checker.timer`:

[Unit]
Description=Run Docker Checker every 5 minutes

[Timer]
OnBootSec=1min
OnUnitActiveSec=5min
Persistent=true

[Install]
WantedBy=timers.target
```
---

### 4. Activate and Verify
```bash
Reload systemd and start service/timer:
sudo systemctl daemon-reload
sudo systemctl start docker-checker.service
sudo systemctl enable --now docker-checker.timer

Check logs:
journalctl -u docker-checker.service -n 200
```