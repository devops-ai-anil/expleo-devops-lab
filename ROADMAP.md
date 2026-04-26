# Expleo DevOps Engineer — Interview Prep Roadmap
**Target Role:** DevOps Engineer | 7–10 Years | Bangalore | Expleo  
**Core Question:** *"Can you run and automate infrastructure reliably from the OS level up?"*

---

## Phase 1: Linux Mastery (Weeks 1–2)

### 1.1 System Administration
- [ ] Process management: `ps`, `top`, `htop`, `kill`, `nice`, `renice`
- [ ] Systemd: `systemctl`, `journalctl`, writing unit files
- [ ] Boot process: GRUB, initrd, runlevels vs targets
- [ ] Cron jobs and `at` scheduling

### 1.2 User & Security Management
- [ ] User/group: `useradd`, `usermod`, `passwd`, `/etc/shadow`
- [ ] sudoers file: `/etc/sudoers`, `visudo`, per-command sudo
- [ ] File permissions: chmod, chown, SUID/SGID/sticky bit, ACLs (`getfacl`/`setfacl`)
- [ ] SSH hardening: key-based auth, `sshd_config`, `fail2ban`
- [ ] SELinux/AppArmor basics: enforcing vs permissive, `audit2allow`

### 1.3 Performance Troubleshooting
- [ ] CPU: `mpstat`, `vmstat`, load average interpretation
- [ ] Memory: `free`, `/proc/meminfo`, swap tuning
- [ ] Disk I/O: `iostat`, `iotop`, `lsblk`, `df`, `du`
- [ ] Network: `ss`, `netstat`, `tcpdump`, `iftop`, `nload`
- [ ] Systematic approach: USE Method (Utilization, Saturation, Errors)

### 1.4 Storage & Networking
- [ ] LVM: `pvcreate`, `vgcreate`, `lvcreate`, extend/reduce
- [ ] Filesystems: `mkfs`, `mount`, `fstab`, NFS/CIFS mounts
- [ ] Networking: `ip addr`, `ip route`, `nmcli`, bonding/teaming
- [ ] Firewall: `firewalld`, `iptables`, `nftables`
- [ ] DNS/hosts resolution: `/etc/resolv.conf`, `dig`, `nslookup`

**Practice Files:** `linux/scripts/`, `linux/security/`, `linux/monitoring/`

---

## Phase 2: Ansible Automation (Weeks 3–4)

### 2.1 Core Concepts
- [ ] Inventory: static, dynamic, groups, `group_vars`, `host_vars`
- [ ] Playbook structure: plays, tasks, handlers, tags
- [ ] Modules: `copy`, `template`, `file`, `service`, `package`, `user`, `cron`
- [ ] Variables: precedence order (16 levels), `register`, `set_fact`
- [ ] Loops: `with_items`, `loop`, `with_dict`
- [ ] Conditionals: `when`, `failed_when`, `changed_when`

### 2.2 Configuration Management
- [ ] Roles: `ansible-galaxy init`, directory structure
- [ ] Jinja2 templates: `{{ var }}`, filters, conditionals in templates
- [ ] Tags: run/skip specific tasks (`--tags`, `--skip-tags`)

### 2.3 Automated Provisioning
- [ ] Idempotency: always verify tasks are idempotent
- [ ] Check mode: `--check --diff`
- [ ] Rolling updates: `serial`, `max_fail_percentage`

### 2.4 Secrets Management
- [ ] Ansible Vault: `ansible-vault create/encrypt/decrypt`
- [ ] Vault in playbooks: `vars_files`, inline `!vault`
- [ ] HashiCorp Vault integration: `community.hashi_vault`

**Practice Files:** `ansible/playbooks/`, `ansible/roles/`

---

## Phase 3: DevOps & CI/CD (Weeks 5–6)

### 3.1 CI/CD Pipeline Management
- [ ] Jenkins: Declarative Pipeline, stages, parallel steps, shared libraries
- [ ] GitHub Actions: workflows, jobs, `uses`, secrets, matrix strategy
- [ ] Pipeline stages: Build → Test → SAST → Package → Deploy → Verify
- [ ] Artifact management: versioning, promotion between environments

### 3.2 Infrastructure as Code
- [ ] Ansible for IaC: idempotent full-stack provisioning
- [ ] Git workflows: GitFlow, trunk-based dev, branch protection
- [ ] Secrets in CI/CD: environment variables, secret scanning

### 3.3 Monitoring & Reliability
- [ ] Prometheus + Alertmanager: scrape configs, alert rules, routing
- [ ] Grafana: dashboards, panels, data sources
- [ ] ELK Stack basics: log shipping, index patterns
- [ ] SLI/SLO/SLA definitions — know the difference

### 3.4 Disaster Recovery
- [ ] Backup strategies: 3-2-1 rule
- [ ] RTO vs RPO: define for a given system
- [ ] Runbooks: document DR procedures
- [ ] Chaos engineering mindset: what breaks first?

**Practice Files:** `cicd/jenkins/`, `cicd/github-actions/`

---

## Phase 4: Mock Interview Drills (Week 7)

### Scenario-Based Questions to Practice
1. "Production server at 100% CPU — walk me through your diagnosis"
2. "Write an Ansible playbook to deploy Nginx with SSL on 50 servers"
3. "Your CI/CD pipeline fails at the deploy stage — how do you debug?"
4. "A developer locked out of their server — how do you recover access?"
5. "How would you harden a fresh RHEL 8 server for production?"
6. "Design a zero-downtime deployment strategy using Ansible"

### Key Numbers to Memorize
- Default SSH port: 22 | HTTPS: 443 | HTTP: 80
- `/etc/passwd` vs `/etc/shadow` — know what's in each
- Ansible fact gathering module: `setup`
- `ansible.cfg` precedence order

---

## Repo Structure

```
expleo-devops-lab/
├── ansible/
│   ├── playbooks/         # Ready-to-run playbooks
│   ├── roles/             # Reusable roles
│   ├── inventory/         # Hosts files
│   ├── group_vars/        # Group-level variables
│   └── vault/             # Encrypted secrets (example)
├── linux/
│   ├── scripts/           # Bash admin scripts
│   ├── monitoring/        # Prometheus/alerting configs
│   ├── security/          # Hardening scripts
│   └── storage/           # LVM / filesystem scripts
├── cicd/
│   ├── jenkins/           # Jenkinsfile examples
│   └── github-actions/    # Workflow YAML files
├── docs/                  # Architecture diagrams, runbooks
├── tests/                 # Ansible molecule tests
└── ROADMAP.md             # This file
```

---

## Quick-Win Practice Commands (Run Daily)

```bash
# Linux drill — run these until they're muscle memory
sudo ss -tulpn                          # open ports
sudo journalctl -u nginx --since today  # service logs
df -hT && lsblk                         # storage overview
top -bn1 | head -20                     # snapshot CPU/mem

# Ansible drill
ansible all -i inventory/hosts -m ping
ansible-playbook playbooks/site.yml --check --diff
ansible-vault encrypt group_vars/all/vault.yml
```
