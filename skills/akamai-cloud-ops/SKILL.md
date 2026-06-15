---
name: akamai-cloud-ops
description: Log in to Akamai Connected Cloud/Linode using API token based access and perform operational verification, domain review, resizing assessment, network troubleshooting, DNS/firewall/load balancer checks, and related cloud administration tasks. Use when Codex needs to inspect or operate Akamai Cloud resources, verify domains or exposed services, investigate connectivity, compare cloud state with Linode hosts, or coordinate with $linode-ssh-troubleshoot. Always require user approval before any write/change action and show command outputs or concise output summaries to the user.
---

# Akamai Cloud Operations

## Overview

Use this skill for Akamai Connected Cloud/Linode API and CLI work. Prefer read-only API checks first, keep credentials out of files and output, load persistent tokens from macOS Keychain when available, and request explicit user approval before any state-changing command.

Read [references/akamai-cloud.md](references/akamai-cloud.md) when you need exact credential formats, CLI/API patterns, or task checklists.

## Safety Rules

- Never store API tokens, personal access tokens, private keys, or copied secrets in this skill, repositories, shell history, or generated docs.
- Accept tokens only at runtime, from macOS Keychain service `akamai-linode-token`, through an existing secure credentials file, or through existing environment variables. Redact tokens in all displayed commands and outputs.
- Treat these as write/change actions requiring approval: creating/updating/deleting instances, firewalls, domains, DNS records, NodeBalancers, volumes, images, tags, backups, IP sharing, support tickets, resizing, rebooting, powering off/on, rebuilding, mutating network rules, and running commands that trigger cloud-side state changes.
- Treat these reads as sensitive and ask approval when appropriate: account users, billing, support tickets, full inventory exports, tokens/scopes, private IP layouts, firewall rules for production assets, and broad fleet scans.
- Show outputs to the user. For noisy JSON, present the command result as a concise table or bullet summary and include exact error lines/status codes.
- If combining with `$linode-ssh-troubleshoot`, use Akamai API data to identify cloud resources, then use SSH only for host-level verification. Follow both skills' approval rules.

## Workflow

1. Resolve the target: domain, instance label/id, IP, firewall id, region, NodeBalancer, volume, or account scope.
2. Identify the operation type:
   - Read-only verification: proceed with scoped commands, redacting credentials.
   - Write/change action: present the exact command/API call, expected impact, rollback path if applicable, and request approval first.
3. Authenticate using macOS Keychain service `akamai-linode-token`, an existing `linode-cli` profile, an Akamai/Linode environment variable, or a temporary runtime token.
4. Run the smallest useful read first, then broaden only when needed.
5. Cross-check from multiple angles for troubleshooting:
   - Cloud object state: instance status, IPs, firewalls, domains, NodeBalancers, volumes.
   - Network path: DNS, public IP reachability, firewall attachment, allowed ports.
   - Host state via `$linode-ssh-troubleshoot` when the target is a known HID Linode.
6. Report findings with the commands run, important output, conclusion, and next action.

## Common Tasks

### Domain Review

- Resolve DNS externally with `dig`/`nslookup`.
- Check Akamai/Linode Domains API for zone records when managed there.
- Compare A/AAAA/CNAME targets against Linode instance public IPs and NodeBalancers.
- Verify TLS endpoint, HTTP status, redirect path, and expected origin/server.
- Flag mismatches between DNS, firewall exposure, and host service listeners.

### Resizing Assessment

- Read current instance plan, region, CPU/RAM/disk, volumes, backups, and host metrics if available.
- Check whether resize requires powered-off state.
- Ask approval before any resize, reboot, shutdown, migration, or volume operation.
- Before changes, capture current plan, label, id, IPs, disks/volumes, backups, and attached firewalls.

### Network Troubleshooting

- Check instance status, public/private IPs, attached firewall, and firewall inbound/outbound rules.
- Check NodeBalancer config and backend health when traffic uses a load balancer.
- Test public reachability with `curl`, `nc`, `dig`, or `openssl s_client`.
- Use `$linode-ssh-troubleshoot` for host listeners, routes, `firewalld`/iptables/nftables, Docker published ports, nginx, and application logs.

## Command Guidance

Prefer official tools when available:

```bash
linode-cli linodes list
linode-cli linodes view <linode_id>
linode-cli firewalls list
linode-cli domains records-list <domain_id>
```

Use direct API calls only when CLI coverage is insufficient or the CLI is unavailable:

```bash
curl -sS -H "Authorization: Bearer $LINODE_TOKEN" https://api.linode.com/v4/linode/instances
```

Do not echo raw token values. When showing a command to the user, write `$LINODE_TOKEN` or `[REDACTED_TOKEN]`.

For the local macOS Keychain setup used on this workstation, load the token for a session with:

```bash
export LINODE_TOKEN="$(security find-generic-password -a "$USER" -s akamai-linode-token -w)"
```

Verify it without revealing it:

```bash
test -n "$LINODE_TOKEN" && echo "LINODE_TOKEN is set"
```

## Approval Template

For write/change actions, ask with this structure:

```text
I need approval to run this Akamai Cloud change:
Target: <resource id/name>
Action: <exact operation>
Command/API: <redacted command>
Expected impact: <downtime/risk/data impact>
Rollback: <rollback or "none available">
```

Proceed only after the user approves.