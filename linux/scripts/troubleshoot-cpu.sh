#!/bin/bash
# Interview scenario: "Production server at 100% CPU — walk me through your diagnosis"
# USE Method: Utilization → Saturation → Errors

set -euo pipefail

LOG="/tmp/cpu_diag_$(date +%Y%m%d_%H%M%S).log"
echo "=== CPU Troubleshooting Report: $(date) ===" | tee "$LOG"

echo -e "\n--- 1. Load Average (1m / 5m / 15m) ---" | tee -a "$LOG"
uptime | tee -a "$LOG"

echo -e "\n--- 2. Top 10 CPU-consuming processes ---" | tee -a "$LOG"
ps aux --sort=-%cpu | head -11 | tee -a "$LOG"

echo -e "\n--- 3. CPU core utilization (mpstat snapshot) ---" | tee -a "$LOG"
if command -v mpstat &>/dev/null; then
    mpstat -P ALL 1 3 | tee -a "$LOG"
else
    vmstat 1 5 | tee -a "$LOG"
fi

echo -e "\n--- 4. Context switches and interrupts ---" | tee -a "$LOG"
vmstat 1 3 | tee -a "$LOG"

echo -e "\n--- 5. Check for zombie processes ---" | tee -a "$LOG"
zombie_count=$(ps aux | awk '$8=="Z"' | wc -l)
echo "Zombie processes: $zombie_count" | tee -a "$LOG"
ps aux | awk '$8=="Z" {print}' | tee -a "$LOG"

echo -e "\n--- 6. Kernel threads vs user threads ---" | tee -a "$LOG"
ps -eo pid,ppid,comm,%cpu --sort=-%cpu | head -15 | tee -a "$LOG"

echo -e "\n--- 7. Check for runaway cron/systemd jobs ---" | tee -a "$LOG"
systemctl list-units --state=running --type=service 2>/dev/null | head -20 | tee -a "$LOG"

echo -e "\n--- 8. Recent OOM killer activity ---" | tee -a "$LOG"
dmesg | grep -i "oom\|killed" | tail -10 | tee -a "$LOG" 2>/dev/null || echo "No dmesg access" | tee -a "$LOG"

echo -e "\n=== Diagnosis complete. Report saved: $LOG ==="
echo "NEXT STEPS:"
echo "  1. If load > CPU count × 2: check I/O wait with 'iostat -x 1 5'"
echo "  2. For single process: strace -p <PID> to see what it's doing"
echo "  3. For Java/JVM: thread dump with 'kill -3 <PID>'"
echo "  4. For rapid response: 'renice +10 <PID>' to lower priority without killing"
