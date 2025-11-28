# Server Health Monitor (systemd + Shell)

## Table of Contents

- [Overview](#overview)
- [Learning Goals](#learning-goals)
- [Requirements / Tasks](#requirements--tasks)
- [Systemd Units & Security](#systemd-units--security)
- [How to Test](#how-to-test)
- [Solution / Implementation](#solution--implementation)

---

## Overview

Server Health Monitor is a shell script that reads CPU, memory, and disk usage, checks specified systemd services, and logs warnings when thresholds are exceeded.
A **systemd timer** schedules periodic checks automatically.

---

## Learning Goals

- Parse output from `top`, `free`, `df` using `awk`
- Implement thresholds and alerting rules
- Read a configuration file for service monitoring
- Write human-readable logs and handle errors
- Create and enable systemd service and timer units

---

## Requirements / Tasks

The script must:

- Read CPU%, memory%, and disk% usage
- Read a list of services from `health-check.conf`
- Log service states (`active`, `inactive`, `failed`, `not-found`)
- Log alerts when thresholds are exceeded
- Keep short history or summary (optional)
- Write logs to `/var/log/health-check.log`

---

## Systemd Units & Security

- Service Unit: `health-check.service` (Type=oneshot)
- Timer Unit: `health-check.timer` (run every 5 minutes)
- User: root required to read metrics and query system services
- Security: can be improved to run as non-root using limited capabilities

---

## How to Test

1. Run manually:

```
sudo /usr/local/bin/health-check.sh
```

2. Check logs:

```
cat /var/log/health-check.log
journalctl -u health-check.service -n 50
```

3. Enable and start timer:

```
sudo systemctl daemon-reload
sudo systemctl enable --now health-check.timer
```

4. Adjust thresholds or stop services to trigger alerts for testing.

---

## Solution / Implementation

### 1. Health-check Script

Initially created at `~/Desktop/Projects/health-check.sh` and tested manually.
Moved to permanent location: `/usr/local/bin/health-check.sh`.

```bash
#!/bin/bash

LOG_FILE="/var/log/health-check.log"

log() {
  echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] $*\n" | tee -a "$LOG_FILE"
}

if [ ! -w "$LOG_FILE" ] 2>/dev/null; then
    sudo mkdir -p "$(dirname "$LOG_FILE")"
    sudo touch "$LOG_FILE"
    sudo chown "$USER":"$USER" "$LOG_FILE" 2>/dev/null || true
fi

log "Health-check script started"

# CPU usage
log "Section_1 :"
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')
log "CPU Usage: $CPU_USAGE%"

# Memory usage
log "Section_2 :"
MEM_USAGE=$(free | awk '/Mem:/ {printf("%.0f"), $3/$2 * 100}')
log "Memory Usage: $MEM_USAGE%"

# Disk usage
log "Section_3 :"
DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
log "Disk Usage: $DISK_USAGE%"

# Thresholds
CPU_THRESHOLD=80
MEM_THRESHOLD=75
DISK_THRESHOLD=90

CPU_INT=$(printf "%.0f" "$CPU_USAGE")

if [ "$CPU_INT" -gt "$CPU_THRESHOLD" ]; then
    log "WARNING: CPU usage is $CPU_USAGE%, exceeds threshold of $CPU_THRESHOLD%"
fi

if [ "$MEM_USAGE" -gt "$MEM_THRESHOLD" ]; then
    log "WARNING: Memory usage is $MEM_USAGE%, exceeds threshold of $MEM_THRESHOLD%"
fi

if [ "$DISK_USAGE" -gt "$DISK_THRESHOLD" ]; then
    log "WARNING: Disk usage is $DISK_USAGE%, exceeds threshold of $DISK_THRESHOLD%"
fi

# Read services from config
if [ -f "$(dirname "$0")/health-check.conf" ]; then
    while read -r service; do
        [[ -z "$service" || "$service" =~ ^# ]] && continue
        if systemctl is-active --quiet "$service"; then
           STATUS=$(systemctl is-active "$service")
        else
           STATUS="not-found"
        fi
        log "Service $service status: $STATUS"
    done < "$(dirname "$0")/health-check.conf"
else
    log "Config file health-check.conf not found"
fi
```

---

### 2. Systemd Service Unit

`/etc/systemd/system/health-check.service`:

```ini
[Unit]
Description=Server Health Check Service
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/health-check.sh
RemainAfterExit=no
User=root

[Install]
WantedBy=multi-user.target
```

---

### 3. Systemd Timer Unit

`/etc/systemd/system/health-check.timer`:

```ini
[Unit]
Description=Run Server Health Check every 5 minutes

[Timer]
OnUnitActiveSec=5min
Persistent=true
Unit=health-check.service

[Install]
WantedBy=timers.target
```

---

### 4. Activate and Verify

```bash
sudo systemctl daemon-reload
sudo systemctl start health-check.service
sudo systemctl enable --now health-check.timer

journalctl -u health-check.service -n 50
```
