#!/bin/bash
# SSH hardening script — run on fresh servers
# Backs up original config before making changes

set -euo pipefail
SSHD_CONFIG="/etc/ssh/sshd_config"
BACKUP="${SSHD_CONFIG}.bak.$(date +%Y%m%d)"

[ "$(id -u)" -ne 0 ] && { echo "Run as root"; exit 1; }

cp "$SSHD_CONFIG" "$BACKUP"
echo "Backed up to $BACKUP"

apply_setting() {
    local key="$1" val="$2"
    if grep -qE "^#?${key}" "$SSHD_CONFIG"; then
        sed -i "s|^#\?${key}.*|${key} ${val}|" "$SSHD_CONFIG"
    else
        echo "${key} ${val}" >> "$SSHD_CONFIG"
    fi
}

apply_setting PermitRootLogin        "no"
apply_setting PasswordAuthentication "no"
apply_setting PubkeyAuthentication   "yes"
apply_setting MaxAuthTries           "3"
apply_setting Protocol               "2"
apply_setting X11Forwarding          "no"
apply_setting ClientAliveInterval    "300"
apply_setting ClientAliveCountMax    "2"
apply_setting AllowAgentForwarding   "no"
apply_setting LoginGraceTime         "30"
apply_setting Banner                 "/etc/ssh/banner"

# Create legal banner
cat > /etc/ssh/banner <<'EOF'
******************************************************************
* Authorized access only. All activity is monitored and logged. *
* Unauthorized access will be prosecuted to the fullest extent. *
******************************************************************
EOF

# Validate before restarting — prevents lockout
sshd -t && echo "Config valid" || { echo "Config ERROR — reverting"; cp "$BACKUP" "$SSHD_CONFIG"; exit 1; }

systemctl restart sshd
echo "SSH hardening applied and sshd restarted"
