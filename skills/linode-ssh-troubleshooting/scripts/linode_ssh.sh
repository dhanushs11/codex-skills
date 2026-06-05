#!/usr/bin/env bash
set -euo pipefail

skill_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
inventory="${LINODE_SSH_INVENTORY:-$skill_dir/references/linodes.tsv}"
key="${LINODE_SSH_KEY:-$HOME/Documents/ssh-keys/yes}"
user="${LINODE_SSH_USER:-root}"
timeout="${LINODE_SSH_CONNECT_TIMEOUT:-10}"

usage() {
  cat >&2 <<'USAGE'
Usage:
  linode_ssh.sh HOST_OR_IP [-- remote-command...]

Examples:
  linode_ssh.sh dev4 -- hostname
  linode_ssh.sh 45.79.33.207 -- 'uptime; df -h'

Environment:
  LINODE_SSH_KEY              
  LINODE_SSH_USER             
  LINODE_SSH_INVENTORY        
  LINODE_SSH_CONNECT_TIMEOUT  
  LINODE_SSH_DRY_RUN=1        
USAGE
}

if [[ $# -lt 1 ]]; then
  usage
  exit 2
fi

target="$1"
shift

if [[ $# -gt 0 && "$1" == "--" ]]; then
  shift
fi

if [[ ! -r "$key" ]]; then
  echo "SSH key is not readable: $key" >&2
  exit 2
fi

resolve_ip() {
  local value="$1"
  if [[ "$value" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    printf '%s\n' "$value"
    return
  fi

  awk -F '\t' -v name="$value" 'NR > 1 && $1 == name { print $2; found=1 } END { exit found ? 0 : 1 }' "$inventory"
}

host_ip="$(resolve_ip "$target")" || {
  echo "Unknown Linode target: $target" >&2
  echo "Known targets:" >&2
  awk -F '\t' 'NR > 1 { print "  " $1 "\t" $2 }' "$inventory" >&2
  exit 2
}

ssh_opts=(
  -i "$key"
  -o IdentitiesOnly=yes
  -o StrictHostKeyChecking=accept-new
  -o ConnectTimeout="$timeout"
)

if [[ "${LINODE_SSH_DRY_RUN:-}" == "1" ]]; then
  printf 'ssh'
  printf ' %q' "${ssh_opts[@]}" "$user@$host_ip" "$@"
  printf '\n'
  exit 0
fi

if [[ $# -eq 0 ]]; then
  exec ssh "${ssh_opts[@]}" "$user@$host_ip"
fi

exec ssh "${ssh_opts[@]}" "$user@$host_ip" "$@"