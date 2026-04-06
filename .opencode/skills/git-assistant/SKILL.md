---
name: git-assistant
description: Git assistant for code review, conventional commits, and pushing changes
license: MIT
compatibility: opencode
---

## What I do

- Review code changes (uncommitted, commits, branches, or PRs)
- Generate Conventional Commits format messages (feat:, fix:, refactor:, docs:, etc.)
- Stage, commit, and push changes to remote

## When to use me

Use this when you need to:
- Review code changes before committing
- Create properly formatted commit messages
- Commit and push changes to the repository

## How to use me

### Review changes

Run one of these commands to get the diff:
- `git diff` - unstaged changes
- `git diff --cached` - staged changes
- `git show <commit>` - specific commit
- `git diff HEAD..<branch>` - compare branch to HEAD
- `gh pr diff <pr-number>` - pull request diff

### Generate Conventional Commit

Analyze the changes and create a commit message following these types:
- `feat:` - new feature
- `fix:` - bug fix
- `refactor:` - code refactoring
- `docs:` - documentation changes
- `style:` - formatting, no code change
- `test:` - adding/updating tests
- `chore:` - maintenance, deps
- `perf:` - performance improvement
- `ci:` - CI changes

Format:
```
<type>: <short description>

- detailed change 1
- detailed change 2
```

### Commit and push

1. Stage files: `git add <files>`
2. Commit with message: `git commit -m "<message>"`
3. Push: `git push`

## Safety rules

- Never run destructive git commands (--force, hard reset) unless explicitly requested
- Never skip hooks (--no-verify) unless explicitly requested
- Warn about unfree packages in NixOS configs
- Check for secrets before committing (.env, credentials.json, etc.)
