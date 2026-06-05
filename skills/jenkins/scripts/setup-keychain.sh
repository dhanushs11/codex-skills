#!/usr/bin/env bash
set -euo pipefail

service="${JENKINS_KEYCHAIN_SERVICE:-codex-jenkins}"

if ! command -v security >/dev/null 2>&1; then
  echo "macOS security command not found; use JENKINS_USER and JENKINS_API_TOKEN instead." >&2
  exit 2
fi

printf "Jenkins username: "
IFS= read -r jenkins_user

printf "Jenkins API token/password: "
stty -echo
IFS= read -r jenkins_token
stty echo
printf "\n"

if [[ -z "$jenkins_user" || -z "$jenkins_token" ]]; then
  echo "Username and token are required." >&2
  exit 2
fi

security add-generic-password -U -s "$service" -a username -w "$jenkins_user" >/dev/null
security add-generic-password -U -s "$service" -a api-token -w "$jenkins_token" >/dev/null

echo "Stored Jenkins credentials in macOS Keychain service: $service"