# TDD Lab Test Environment

This task extends the base VM setup with a test-driven development environment for student courses (e.g. OOP, web programming). Each student's VM comes preloaded with exercise placeholder files and pre-written unit tests. A dedicated teacher server collects test results and displays a live progress dashboard.

## Overview

```
Student VM  ──pytest──▶  conftest.py hook  ──POST results──▶  Server VM (:5000)
                                                                      │
                                          Teacher browser ◀── dashboard
```

- **Student VMs** (`task2_vms` Ansible group): each student gets `~/exercises/` with placeholder Python files to implement and pre-written tests to pass.
- **Server VM** (`task2_server` Ansible group): runs a lightweight Flask app that receives test results and shows a per-student progress table.

## Prerequisites

- Terraform infrastructure deployed (`tofu apply`)
- Ansible collections installed: `ansible-galaxy collection install -r requirements.yml`

## Deployment

Run in order:

```bash
# 1. Set up the result server
ansible-playbook tdd_server.yml

# 2. Set up all student VMs
ansible-playbook tdd_students.yml
```

## Student Workflow

SSH into your VM and run pytest in the exercises directory:

```bash
cd ~/exercises
pytest
```

Test results are automatically posted to the teacher's dashboard after every run. No extra steps needed.

## Teacher Workflow

Open a browser and navigate to:

```
http://<server-vm-ip>:5000
```

The dashboard shows each student's passed/failed/total test count and the time of their last run. It auto-refreshes every 30 seconds.

To find the server IP:

```bash
cd terraform
tofu output vm_info
```

## Swapping Out Exercises

The exercise files are under `ansible/files/tdd_student/`. To replace the calculator example with a different exercise:

1. Edit or replace `files/tdd_student/exercises/<module>.py` with new placeholder stubs.
2. Edit or replace `files/tdd_student/tests/test_<module>.py` with new tests.
3. Re-run `ansible-playbook tdd_students.yml` — existing files are not overwritten (`force: false`) unless you delete them on the VMs first.

## File Structure

```
ansible/
  tdd_server.yml                    # Playbook: configures the teacher server VM
  tdd_students.yml                  # Playbook: configures all student VMs
  files/
    tdd_server/
      app.py                        # Flask result receiver + dashboard
      templates/dashboard.html      # Dashboard HTML template
      tdd_lab.service               # systemd unit for the Flask app
    tdd_student/
      conftest.py                   # pytest hook: auto-posts results after each run
      exercises/calculator.py       # Placeholder exercise (students implement this)
      tests/test_calculator.py      # Pre-written tests (students must not edit these)
```
