---
description: Generate one-line commit message from staged changes
subtask: false
---

Review the staged Git changes below.

Staged diff:
!`git diff --cached`

Generate exactly one commit message using Conventional Commits format.

Format:
<type>[optional scope]: <imperative description>

Rules:
- Use Conventional Commits.
- Allowed types: feat, fix, refactor, docs, test, perf, build, ci, chore, revert.
- Maximum length: 72 characters, including the type and scope.
- Use English.
- Use imperative mood.
- Do not end with a period.
- Describe the user-facing effect or maintenance purpose, not just the files changed.
- Use only the staged diff.
- Do not include a body.
- Do not include quotes, Markdown, prefixes, explanations, or trailing whitespace.
- Do not modify the repository.
- Never run commands that modify the working tree or Git index. In particular,
  do not run git add, git commit, git reset, git restore, git checkout, git amend, or git push.
- Do not run git add, commit, reset, amend, or push.
- If the staged diff is empty, output exactly: NO_STAGED_CHANGES.
