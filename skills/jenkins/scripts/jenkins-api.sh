#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat >&2 <<'USAGE'
Usage:
  jenkins_api.sh METHOD PATH [curl-args...]

Environment:
  JENKINS_URL        Defaults to 
  JENKINS_USER       Jenkins username
  JENKINS_API_TOKEN  Jenkins API token or password

Examples:
  jenkins_api.sh GET /api/json
  jenkins_api.sh GET "/job/my-job/lastBuild/consoleText"
  jenkins_api.sh POST "/job/my-job/build"
  jenkins_api.sh POST "/job/my-job/buildWithParameters" --data-urlencode BRANCH=main
USAGE
}

if [[ $# -lt 2 ]]; then
  usage
  exit 2
fi

method="$1"
path="$2"
shift 2

base_url="${JENKINS_URL:-}"
keychain_service="${JENKINS_KEYCHAIN_SERVICE:-}"
user="${JENKINS_USER:-}"
token="${JENKINS_API_TOKEN:-}"

keychain_get() {
  local account="$1"
  if command -v security >/dev/null 2>&1; then
    security find-generic-password -s "$keychain_service" -a "$account" -w 2>/dev/null || true
  fi
}

if [[ -z "$user" ]]; then
  user="$(keychain_get username)"
fi

if [[ -z "$token" ]]; then
  token="$(keychain_get api-token)"
fi

if [[ -z "$user" || -z "$token" ]]; then
  echo "JENKINS_USER and JENKINS_API_TOKEN must be set, or store them in macOS Keychain with scripts/setup_keychain.sh." >&2
  exit 2
fi

netrc_file="$(mktemp "${TMPDIR:-/tmp}/jenkins-netrc.XXXXXX")"
trap 'rm -f "$netrc_file"' EXIT
chmod 600 "$netrc_file"

host="$(printf '%s\n' "$base_url" | sed -E 's#^https?://([^/]+)/?.*$#\1#')"
cat > "$netrc_file" <<EOF
machine $host
login $user
password $token
EOF

url="${base_url%/}/${path#/}"
curl_args=(-fsS -g --netrc-file "$netrc_file" -X "$method")

case "$method" in
  POST|PUT|PATCH|DELETE)
    crumb_json="$(curl -fsS --netrc-file "$netrc_file" "${base_url%/}/crumbIssuer/api/json" 2>/dev/null || true)"
    if [[ -n "$crumb_json" ]]; then
      crumb_field="$(printf '%s' "$crumb_json" | sed -n 's/.*"crumbRequestField"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')"
      crumb_value="$(printf '%s' "$crumb_json" | sed -n 's/.*"crumb"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')"
      if [[ -n "$crumb_field" && -n "$crumb_value" ]]; then
        curl_args+=(-H "${crumb_field}: ${crumb_value}")
      fi
    fi
    ;;
esac

curl "${curl_args[@]}" "$url" "$@"