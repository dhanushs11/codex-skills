---
name: linode-ssh
description: SSH into known Linode servers using the local key for administration, setup, maintenance, deployment support, diagnostics, and troubleshooting. Use when Codex needs to inspect, configure, install, repair, or operate one of the named Linodes from the inventory. Always require user approval before any remote write/change command and before important or sensitive read commands.
---

# Linode SSH Access

## Overview

Use this skill to work on the known Linode fleet through SSH. It supports general server administration, setup, maintenance, deployment assistance, diagnostics, and troubleshooting. Keep commands scoped and ask for approval before remote actions that may be sensitive, expensive, disruptive, or state-changing.

## Common Uses

- inspect OS, disk, memory, processes, services, network listeners, and logs
- install or configure packages after explicit approval
- set up services, users, directories, permissions, cron jobs, certificates, or app dependencies after explicit approval
- support deployments, service checks, and rollback investigation
- diagnose failed jobs, application errors, capacity issues, and connectivity problems

## Host Inventory

Read `references/linodes.tsv` when mapping a host name to an IP address. Use the exact host names from that inventory when reporting what was inspected.

```

Default SSH user:

```bash
root
```

If `root` fails, try likely operational users only after explaining the fallback, such as the current local username or `deploy`.

## Connection Workflow

1. Identify the target Linode by name or IP. If the user gives a partial name, match against `references/linodes.tsv` and state the resolved host.
2. Build commands with `scripts/linode_ssh.sh` where practical; it applies the inventory, key, strict key-checking defaults, and a timeout.
3. For a basic connection probe or initial context, use harmless reads such as `hostname`, `uptime`, `whoami`, `uname -a`, or `cat /etc/os-release`.
4. For setup or maintenance requests, inspect current state first, then propose the exact write/change commands and request approval before running them.
5. Keep command output concise. Summarize noisy logs and include exact error lines when they matter.
6. Never run broad fleet-wide loops unless the user explicitly asks for multiple hosts and the commands are low risk.

```

## Approval Rules

Ask for explicit user approval before running remote write/change commands, including:

- package installs, upgrades, removals, or repository changes
- service restarts/reloads/stops/starts
- file edits, deletes, moves, permission changes, ownership changes, or uploads
- database writes, migrations, cache flushes, queue drains, reindexing, or application CLI commands that mutate state
- firewall/network/routing changes
- Docker/Kubernetes/container commands that stop, remove, restart, exec with mutation, prune, or change deployed state
- commands using `sudo`, `su`, `doas`, shell redirection to remote files, or destructive flags

Ask for approval before important or sensitive read commands, including:

- reading secrets, credentials, tokens, private keys, `.env` files, or application config likely to contain secrets
- dumping databases or running queries that expose user/customer/business data
- reading large production logs, security logs, audit logs, mail queues, or access logs
- recursive filesystem scans over large or sensitive directories
- commands that may be expensive or disruptive despite being read-only, such as `find /`, `du -sh /*`, or high-cardinality log searches

Routine low-risk reads usually do not need pre-approval:

- `hostname`, `uptime`, `date`, `whoami`, `id`
- `df -h`, `free -m`, `vmstat 1 5`, `top -b -n1` or equivalent
- service status checks such as `systemctl status name --no-pager` when the service name is known
- short, targeted log tails after explaining the path, such as `journalctl -u nginx -n 100 --no-pager`

When approval is required, state the host, exact command, and why the command is sensitive or state-changing.

## Troubleshooting Patterns

For host health:

```bash
scripts/linode_ssh.sh dev4 -- 'hostname; uptime; df -h; free -m'
```

For a known systemd service:

```bash
scripts/linode_ssh.sh dev4 -- 'systemctl status nginx --no-pager'
scripts/linode_ssh.sh dev4 -- 'journalctl -u nginx -n 100 --no-pager'
```

For network checks from the Linode:

```bash
scripts/linode_ssh.sh dev4 -- 'ip addr; ip route; ss -tulpn'
```

Treat `ss -tulpn` as routine when checking local listeners, but ask approval before broad packet capture, firewall changes, or commands that reveal credentials in process arguments.

## Safety

Do not store private key material, passwords, tokens, or copied server secrets in the skill or repository. Do not add host keys with `StrictHostKeyChecking=no`; use `accept-new` so unexpected host key changes remain visible.