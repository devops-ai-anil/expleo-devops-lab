# expleo-devops-lab

Practice lab for Expleo DevOps Engineer interview (7–10 years experience).
Covers Linux administration, Ansible automation, and CI/CD pipeline management end-to-end.

## Quick Start

```bash
# 1. Set up Ansible environment
pip install ansible ansible-lint

# 2. Test connectivity
ansible all -i ansible/inventory/hosts -m ping

# 3. Run security hardening (dry-run first)
ansible-playbook ansible/playbooks/security-hardening.yml \
  -i ansible/inventory/hosts --check --diff

# 4. Deploy Nginx (rolling, one server at a time)
ansible-playbook ansible/playbooks/nginx-deploy.yml \
  -i ansible/inventory/hosts

# 5. Run Linux CPU troubleshooter
bash linux/scripts/troubleshoot-cpu.sh
```

## Study Path

| Week | Focus | Files |
|------|-------|-------|
| 1–2 | Linux admin & security | `linux/scripts/`, `linux/security/` |
| 3–4 | Ansible playbooks & roles | `ansible/playbooks/` |
| 5–6 | CI/CD pipelines | `cicd/jenkins/`, `cicd/github-actions/` |
| 7 | Mock interviews | `docs/interview-cheatsheet.md` |

## Key Files

- [ROADMAP.md](ROADMAP.md) — Week-by-week prep plan
- [docs/interview-cheatsheet.md](docs/interview-cheatsheet.md) — Top 10 questions + answers
- [docs/disaster-recovery-runbook.md](docs/disaster-recovery-runbook.md) — DR scenarios
- [ansible/playbooks/nginx-deploy.yml](ansible/playbooks/nginx-deploy.yml) — Rolling deploy example
- [ansible/playbooks/security-hardening.yml](ansible/playbooks/security-hardening.yml) — CIS hardening
- [cicd/jenkins/Jenkinsfile](cicd/jenkins/Jenkinsfile) — Full pipeline with approval gate
- [linux/scripts/troubleshoot-cpu.sh](linux/scripts/troubleshoot-cpu.sh) — CPU diagnosis script
# expleo-devops-lab
