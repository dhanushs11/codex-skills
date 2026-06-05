---
name: commit-message-convention
description: Draft, review, rewrite, and validate Git commit messages using the project's commit convention. Use when the user asks for a commit message, commit subject, commit body, commit guidelines, or to make a git commit. Enforce imperative voice, an `area:` prefix, a 50-character subject limit, no subject full stop, a blank line before the body, 72-character body wrapping, self-contained problem/solution/alternatives rationale, and explicit user approval before every `git commit`.
---

# Commit Message Convention

Use this skill when the user asks for a commit message, commit subject,
commit body, commit guidelines, or a review of an existing commit message.

## Commit Safety

- Always ask for explicit user approval before running `git commit`.
- Ask every time, even if the user approved a previous commit in the same
  session.
- Drafting, editing, or validating commit messages does not require approval.
- Do not infer approval from a request to prepare, stage, or suggest a commit.

## Required Format

Write commit messages in this shape:

```text
area: Imperative subject without a full stop

Short paragraph explaining the problem, if useful.

- Describe the important change
- Explain why this approach solves the problem
- Note alternatives considered and discarded, if any
```

## Subject Rules

- Start with `area:`, where `area` identifies the project area changed.
- Keep the first line to 50 characters or less.
- Use imperative voice, as if ordering the codebase to change behavior.
- Do not end the subject with a full stop.
- Follow the subject with a blank line when a body is present.
- Avoid context that only makes sense with external resources.

Good subject examples:

```text
checkout: Validate stored payment tokens
cms: Skip unpublished hero variants
search: Normalize facet labels
```

Avoid:

```text
checkout: Validated stored payment tokens.
cms: Fixes issue from Slack thread
search: Normalized facet labels
```

## Body Rules

- Wrap body lines at 72 characters or less.
- Begin with a short descriptive paragraph when it clarifies the problem.
- Prefer a bulleted list for concrete changes.
- Explain what was wrong with the current code.
- Justify why the new approach is better.
- Include alternatives considered and discarded when relevant.
- Omit the body only for trivial changes where the subject is enough.

## Workflow

1. Identify the changed project area from filenames, modules, package names,
   feature names, or the user's description.
2. Draft a concise imperative subject using `area: Verb object`.
3. Count the subject characters and tighten it if it exceeds 50 characters.
4. Add a blank line and body when the change is non-trivial.
5. Make the body self-contained: problem, solution, and tradeoffs should be
   understandable without issue trackers, chat links, or external docs.
6. Check body wrapping at 72 characters and reflow before returning it.

## Output Guidance

When the user asks for one commit message, return only the commit message in a
plain fenced code block unless they ask for explanation. When reviewing a
message, lead with violations and then provide a corrected version.