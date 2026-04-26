# Expleo Interview Cheat Sheet
**Study this the night before. Answers to the 10 most likely questions.**

---

## Q1. "Production server 100% CPU — what do you do?"
```
1. uptime                           → check load vs CPU count
2. ps aux --sort=-%cpu | head -10   → find the culprit process
3. top -p <PID>                     → watch it live
4. strace -p <PID>                  → what syscalls is it making?
5. If load > CPUs: check iostat -x (maybe it's I/O wait, not CPU)
6. Immediate relief: renice +10 <PID> (don't kill without knowing why)
7. Root cause: journalctl -u <service> or check app logs
```

## Q2. "Disk at 90% — fix it without downtime"
```
1. df -hT && du -sh /var/log/* | sort -h | tail   → find what's using space
2. Check if log rotation is working: logrotate -vf /etc/logrotate.conf
3. If LVM: lvextend -L +20G /dev/vg/lv && xfs_growfs /mountpoint
4. If not LVM: add disk, create PV/VG/LV, extend (see lvm-extend.sh)
Key: xfs_growfs works online. resize2fs works online for ext4.
```

## Q3. "Write an Ansible playbook to deploy Nginx with SSL on 50 servers"
```yaml
Key points to mention:
- serial: 5  (rolling — do 5 at a time, not all 50 at once)
- handlers for reload vs restart (reload = no downtime)
- validate: "nginx -t -c %s"  (never push broken config)
- uri module to verify each server responds after deploy
- firewalld to open 80/443
→ See: ansible/playbooks/nginx-deploy.yml
```

## Q4. "How do you manage secrets in Ansible?"
```
1. ansible-vault encrypt group_vars/all/vault.yml
2. Reference in playbook: vars_files: [vault.yml]
3. Run: ansible-playbook site.yml --ask-vault-pass
   OR:   ansible-playbook site.yml --vault-password-file .vaultpass
4. For CI/CD: store vault password in Jenkins credentials / GitHub Secrets
5. Advanced: HashiCorp Vault + community.hashi_vault lookup plugin
NEVER: put secrets in plain vars.yml or in the playbook itself
```

## Q5. "CI/CD pipeline fails at deploy stage — debug it"
```
1. Read the error message carefully (95% of the answer is there)
2. Run with verbose: ansible-playbook ... -vvv
3. Check --check --diff to see what it would change
4. SSH to target host manually and verify state
5. Check if it's an idempotency issue (task not safe to re-run)
6. Verify inventory/variables are correct for that environment
```

## Q6. "How do you do a zero-downtime deployment?"
```
Ansible approach:
- serial: 1 (or %) → one host at a time
- pre_tasks: remove host from load balancer
- Deploy new version
- Verify health endpoint responds
- post_tasks: re-add to load balancer
Key: health check BEFORE next host, max_fail_percentage: 0
```

## Q7. "Difference between SLI, SLO, SLA?"
```
SLI (Indicator): the actual measurement — e.g., "request latency p99"
SLO (Objective):  your target — e.g., "p99 < 200ms for 99.9% of requests"
SLA (Agreement):  the contract with penalty — e.g., "if SLO breached, credit given"
Error budget = 1 - SLO = how much downtime you're allowed
```

## Q8. "Harden a fresh RHEL 8 server for production"
```
1. Disable root SSH + password auth (see ssh-hardening.sh)
2. Deploy SSH keys only
3. firewalld: deny all, whitelist needed ports
4. SELinux: enforcing mode
5. Disable unused services (bluetooth, cups, avahi)
6. sysctl: kernel hardening (no IP forwarding, no redirects)
7. Password aging: PASS_MAX_DAYS 90
8. Enable auditd for compliance logging
→ See: ansible/playbooks/security-hardening.yml
```

## Q9. "What's your disaster recovery strategy?"
```
Framework: RTO + RPO first, then design backup around it
- RTO (Recovery Time Objective): how long until service is back?
- RPO (Recovery Point Objective): how much data loss is acceptable?
3-2-1 backup rule: 3 copies, 2 media types, 1 offsite
For infra: Ansible playbooks ARE your DR — rebuild from code in <1hr
Document: runbooks, tested quarterly, not just written
```

## Q10. "What is Ansible idempotency and why does it matter?"
```
Idempotent = running a playbook 10 times has same result as running once
Why: safe to re-run on failures, safe for CI/CD, no "drift"
How to verify: ansible-playbook site.yml --check → should show 0 changes
Common mistake: shell/command modules are NOT idempotent by default
Fix: use creates= or removes= params, or use proper modules (package, service)
```

---

## Numbers & Defaults (memorize these)
| Item | Value |
|------|-------|
| SSH default port | 22 |
| Ansible fact module | `setup` |
| Ansible config precedence | env var > playbook dir > ~/.ansible.cfg > /etc/ansible/ansible.cfg |
| Variable precedence | `extra_vars` wins, role defaults lose |
| `/etc/passwd` fields | username:x:uid:gid:comment:home:shell |
| `/etc/shadow` fields | username:hash:lastchange:min:max:warn:inactive:expire |
| LVM order | pvcreate → vgcreate → lvcreate → mkfs → mount |
