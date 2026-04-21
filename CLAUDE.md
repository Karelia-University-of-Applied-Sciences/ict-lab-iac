# CLAUDE.md

This file provides guidance for AI assistants (Claude, Copilot, etc.) working with this repository.

## Project Overview

Thesis project demonstrating Infrastructure-as-Code (IaC) using **Terraform** and **Ansible** on a Nutanix virtualization platform. The repository contains multiple implementation tasks of increasing complexity.

## Repository Structure

```
implementation/
  task_example/       # Template/reference task (Terraform only, modules commented out)
  task1/              # Terraform only — provisions VMs per student user
  task2/              # Terraform + Ansible — MQTT broker, MariaDB, per-student VMs
  task3/              # Terraform + Ansible — PKI Root CA + HTTPS load balancer + HTTPS web servers
  terraform_modules/
    nutanix_project/  # Reusable module: creates a Nutanix project
    nutanix_vm/       # Reusable module: provisions a VM with cloud-init user management
thesis_report/        # Code examples used in the written thesis
```

## Key Conventions

### Terraform

- Provider: `nutanix/nutanix` (Prism Central API); TLS verification disabled (`insecure = true`) due to self-signed cert in the lab — this is a documented, intentional deviation.
- Provider: `ansible/ansible` (task2, task3) — writes Ansible inventory from Terraform state via `ansible_host` resources.
- Modules live in `implementation/terraform_modules/` and are referenced with relative paths.
- Sensitive vars (`nutanix_password`, `ubuntu_password`, etc.) are never committed; use `*.tfvars` files (git-ignored). See `*.tfvars.example` for required keys.
- State files (`terraform.tfstate*`) are committed locally for lab continuity — **do not delete them**.
- Run `terraform fmt` and `terraform validate` before committing.

### Ansible

- Inventory is dynamic: task2 and task3 use `cloud.terraform.terraform_provider` plugin sourced from Terraform state.
- Playbooks are in `implementation/taskN/ansible/`.
- `ansible.cfg` sets `host_key_checking = False` and `interpreter_python = auto_silent` for lab convenience.
- Use FQCN for all modules (e.g., `ansible.builtin.package`, `community.general.ufw`).
- Follow the style guide in `.claude/rules/ansible.instructions.md`.

### Style Rules

- **Terraform**: 2-space indent, alphabetize attributes, `depends_on` at top, `lifecycle` at bottom. Full rules: `.claude/rules/terraform.instructions.md`.
- **Ansible**: 2-space indent, `snake_case` variables, single quotes preferred, tasks ordered as `name → module → params → loop → become → tags`. Full rules: `.claude/rules/ansible.instructions.md`.

## Infrastructure Details (Lab Environment)

All environment-specific values (Prism Central endpoint, cluster/subnet/image UUIDs) are defined in `*.tfvars` files, which are git-ignored. See `*.tfvars.example` in each task directory for required keys.

## Common Commands

```bash
# Terraform
cd implementation/taskN/terraform
terraform init
terraform plan
terraform apply
terraform fmt -recursive

# Ansible (task2)
cd implementation/task2/ansible
ansible -m ping all
ansible-playbook mqtt.yml
ansible-lint

# Ansible (task3)
cd implementation/task3/ansible
ansible-galaxy collection install -r requirements.yml
ansible -m ping all
ansible-playbook site.yml   # deploys CA → web servers → load balancer
```

## What NOT to Do

- Do not commit `*.tfvars`, `*.tfstate`, or any file containing credentials or secrets.
- Do not remove or overwrite existing `terraform.tfstate` files without explicit instruction.
- Do not run `terraform destroy` without explicit user confirmation.
- Do not add unnecessary abstractions; modules are only used for groups of related resources reused across tasks.
