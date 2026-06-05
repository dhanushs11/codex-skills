---
name: jenkins
description: Work with Jenkins at using credentials provided at runtime. Use when Codex needs to log in to Jenkins, inspect jobs/builds/logs, trigger parameterized or non-parameterized builds, manage job configuration, download artifacts, compare Jenkins state, or make Jenkins task/change/implementation updates. Never store credentials in the skill or repository.
---

# Jenkins

## Overview

Use Jenkins through the API whenever possible. Use browser login only when the
API is insufficient or the user specifically asks for UI navigation.

Do not persist user credentials in skill files, repositories, shell history, or
logs. Ask for credentials at runtime or use environment variables already
provided by the user/session.

## Authentication

Prefer these runtime environment variables when credentials are provided for a
single session:

```bash
export JENKINS_URL=""
export JENKINS_USER="<username>"
export JENKINS_API_TOKEN="<api-token-or-password>"
```

Prefer a Jenkins API token over a password. If the user provides a password and
the task can be done through the API, ask whether they can provide an API token.

Use `scripts/jenkins_api.sh` for API calls. The script writes credentials only
to a temporary `netrc` file under `/tmp`, deletes it on exit, and adds a Jenkins
crumb header automatically for state-changing requests.

For reusable local credentials on macOS, use Keychain. Run this once:

```bash
scripts/setup_keychain.sh
```

The helper then falls back to Keychain service `codex-jenkins` when
`JENKINS_USER` or `JENKINS_API_TOKEN` are not set.

## Workflow

1. Confirm the requested Jenkins target: job URL/name, branch, build number, or
   implementation goal.
2. Verify credentials are available through runtime environment variables or
   ask the user to provide them for this session.
3. Inspect before changing:
   - Job metadata: `GET /job/<name>/api/json`
   - Latest build: `GET /job/<name>/lastBuild/api/json`
   - Console log: `GET /job/<name>/<build>/consoleText`
4. For changes, summarize the intended action and ask for explicit approval
   before triggering builds, modifying config, disabling jobs, deleting builds,
   installing plugins, or changing credentials.
5. After any change, verify Jenkins state and report exact build/job links.

## API Examples

Fetch Jenkins root metadata:

```bash
scripts/jenkins_api.sh GET /api/json
```

Fetch a job:

```bash
scripts/jenkins_api.sh GET "/job/my-job/api/json"
```

Fetch a console log:

```bash
scripts/jenkins_api.sh GET "/job/my-job/123/consoleText"
```

Trigger a build only after user approval:

```bash
scripts/jenkins_api.sh POST "/job/my-job/build"
```

Trigger a parameterized build only after user approval:

```bash
scripts/jenkins_api.sh POST "/job/my-job/buildWithParameters" \
  --data-urlencode "BRANCH=main"
```