
## Common Endpoints

- Root metadata: `GET /api/json`
- Job metadata: `GET /job/<job>/api/json`
- Nested folder job: `GET /job/<folder>/job/<job>/api/json`
- Last build metadata: `GET /job/<job>/lastBuild/api/json`
- Build console: `GET /job/<job>/<build-number>/consoleText`
- Build artifacts: `GET /job/<job>/<build-number>/artifact/<path>`
- Queue item: `GET /queue/item/<id>/api/json`
- Trigger build: `POST /job/<job>/build`
- Trigger parameterized build: `POST /job/<job>/buildWithParameters`
- Job config: `GET /job/<job>/config.xml`
- Update job config: `POST /job/<job>/config.xml` with `Content-Type: application/xml`

## Safety Rules

- Treat triggering a build as a change. Ask for approval first.
- Treat modifying config XML as a high-risk change. Download and inspect the
  current `config.xml`, prepare a diff, then ask for approval before posting it.
- Never print credentials, tokens, cookies, crumb values, or full auth headers.
- Prefer API tokens. Password login may fail if SSO or MFA is enforced.
- For folders, encode each folder level as `/job/<name>`.
- Prefer macOS Keychain for reusable local credentials. Do not store tokens in
  skill files, repositories, command examples, committed `auth` files, or logs.

## Debugging

- `401` usually means missing or invalid credentials.
- `403 No valid crumb` means the request needs a crumb header; use the helper
  script so it fetches one automatically.
- `404` often means the job path is wrong or a folder segment is missing.
- After triggering a build, Jenkins may return a `Location` header for the queue
  item. Poll that queue URL until it exposes an executable build URL.