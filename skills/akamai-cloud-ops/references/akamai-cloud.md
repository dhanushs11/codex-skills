interface:
  display_name: "Akamai Cloud Ops"
  short_description: "Operate Akamai Cloud with approval gates"
  default_prompt: "Use $akamai-cloud-ops to review an Akamai domain and verify its DNS, CDN, and origin configuration."
saiphanidhanush.satyavolu@sdhanush12 agents % cd ..
saiphanidhanush.satyavolu@sdhanush12 akamai-cloud-ops % ls
agents          references      SKILL.md
saiphanidhanush.satyavolu@sdhanush12 akamai-cloud-ops % cd references
saiphanidhanush.satyavolu@sdhanush12 references % ls
akamai-cloud.md
saiphanidhanush.satyavolu@sdhanush12 references % cat akamai-cloud.md
# Akamai Connected Cloud Reference

## Credential Handling

Use one of these patterns, in this order:

1. macOS Keychain item `akamai-linode-token` for this workstation.
2. Existing `linode-cli` config/profile if already present.
3. Existing environment variable such as `LINODE_TOKEN`.
4. User-provided runtime token for the current task.

Do not write a token into this skill, a repository, logs, docs, or shell history. If a command must include a token, keep it in an environment variable and redact it when reporting.

Common credential checks:

```bash
security find-generic-password -a "$USER" -s akamai-linode-token -w >/dev/null
export LINODE_TOKEN="$(security find-generic-password -a "$USER" -s akamai-linode-token -w)"
test -n "$LINODE_TOKEN" && echo "LINODE_TOKEN is set"
linode-cli profile view
linode-cli --json profile view
env | grep -E '^LINODE_TOKEN='
```

When testing Keychain token authentication, show only status and non-secret response shape:

```bash
curl -sS -o /dev/null -w '%{http_code}\n' \
  -H "Authorization: Bearer $LINODE_TOKEN" \
  https://api.linode.com/v4/profile
```

If `linode-cli` is unavailable, use the v4 API directly:

```bash
curl -sS -H "Authorization: Bearer $LINODE_TOKEN" https://api.linode.com/v4/account
```

## Read-Only Checks

Account and inventory:

```bash
linode-cli --json account view
linode-cli --json linodes list
linode-cli --json firewalls list
linode-cli --json nodebalancers list
linode-cli --json volumes list
linode-cli --json domains list
```

Specific resources:

```bash
linode-cli --json linodes view <linode_id>
linode-cli --json linodes ips-list <linode_id>
linode-cli --json firewalls view <firewall_id>
linode-cli --json firewalls devices-list <firewall_id>
linode-cli --json nodebalancers view <nodebalancer_id>
linode-cli --json nodebalancers configs-list <nodebalancer_id>
linode-cli --json domains records-list <domain_id>
```

External verification:

```bash
dig +short A example.com
dig +short AAAA example.com
curl -k -sS -o /dev/null -w '%{http_code} %{remote_ip} %{ssl_verify_result}\n' https://example.com/
openssl s_client -connect example.com:443 -servername example.com </dev/null
```

## Write/Change Examples

Require user approval before any of these:

```bash
linode-cli linodes resize <linode_id> --type <plan_id>
linode-cli linodes reboot <linode_id>
linode-cli linodes shutdown <linode_id>
linode-cli firewalls rules-update <firewall_id> ...
linode-cli domains records-create <domain_id> ...
linode-cli domains records-update <domain_id> <record_id> ...
linode-cli nodebalancers config-update <nodebalancer_id> <config_id> ...
```

Before a change, capture current state with `--json` and summarize the relevant fields to the user. After a change, run the same read-only checks again and compare.

## Domain Review Checklist

1. Resolve public DNS records.
2. Identify whether the domain is managed in Akamai/Linode DNS.
3. Match DNS targets to Linode public IPs, NodeBalancers, or external origins.
4. Check Akamai/Linode firewall attachment for the target instance.
5. Verify ports and protocol from outside.
6. If a known HID Linode is involved, use `$linode-ssh-troubleshoot` to inspect listeners, nginx, Docker published ports, local firewall, and application health.
7. Report mismatch, exposure, and remediation options separately.

## Resize Checklist

1. Read current plan, status, disk layout, volumes, backups, and region.
2. Check if target plan supports disk size and region constraints.
3. Identify expected downtime and whether shutdown is required.
4. Ask approval with the exact resize command.
5. After resize, verify plan, boot status, disk size, service health, and application endpoints.

## Network Troubleshooting Checklist

1. Confirm instance status and IPs.
2. Confirm cloud firewall attachment and inbound/outbound rules.
3. Check NodeBalancer path if present.
4. Test DNS and TCP/TLS externally.
5. Use host SSH only after cloud-side checks identify the target.
6. Separate cloud firewall findings from host firewall findings.