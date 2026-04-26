# Disaster Recovery Runbook
**RTO Target: 2 hours | RPO Target: 1 hour**

---

## Scenario 1: Web Server Unresponsive

### Detection
- Prometheus alert: `ServiceDown` fires after 1 min
- On-call receives PagerDuty notification

### Response Steps
```bash
# 1. Check if host is reachable
ping -c 3 <host_ip>
ssh devops@<host_ip>

# 2. If SSH works — check the service
sudo systemctl status nginx
sudo journalctl -u nginx --since "10 minutes ago"
sudo nginx -t                        # validate config

# 3. Restart if config is valid
sudo systemctl restart nginx

# 4. If host unreachable — rebuild from Ansible
ansible-playbook ansible/playbooks/site.yml \
  -i ansible/inventory/hosts \
  --limit web01 \
  --vault-password-file .vaultpass
```

**Resolution time target: 15 minutes**

---

## Scenario 2: Full Server Rebuild

### When to use
- Hardware failure
- Ransomware / security incident
- Corrupt OS

### Steps
```bash
# 1. Provision new VM (Terraform/cloud console)
# 2. Add new IP to inventory
vim ansible/inventory/hosts

# 3. Full rebuild from code
ansible-playbook ansible/playbooks/site.yml \
  -i ansible/inventory/hosts \
  --limit <new_host> \
  --vault-password-file .vaultpass

# 4. Restore data from backup
rsync -avz backup-server:/backups/app-data/ /opt/app/data/

# 5. Verify health endpoint
curl -sf https://<new_host>/health
```

**Resolution time target: 1 hour**

---

## Scenario 3: Database Corruption / Data Loss

### RPO Decision Tree
```
Data loss acceptable < 1hr? → restore from hourly snapshot
Data loss acceptable < 24hr? → restore from daily backup
Full rebuild needed? → restore from weekly full backup + apply WAL logs
```

### Restore Procedure
```bash
# PostgreSQL example
systemctl stop postgresql
pg_restore -d mydb /backups/mydb_$(date +%Y%m%d).dump
systemctl start postgresql
psql -c "SELECT count(*) FROM critical_table;"  # verify row count
```

---

## Backup Schedule
| Type | Frequency | Retention | Location |
|------|-----------|-----------|----------|
| Full backup | Weekly (Sun 02:00) | 4 weeks | offsite S3 |
| Incremental | Daily (02:00) | 2 weeks | local + S3 |
| Log files | Hourly | 72 hours | local |
| Config (Ansible) | Every commit | Forever | Git |

---

## Post-Incident Checklist
- [ ] Service restored and verified
- [ ] Root cause identified
- [ ] Timeline documented
- [ ] Monitoring/alerting improved to catch earlier next time
- [ ] Runbook updated with new findings
- [ ] Incident report written within 48 hours
