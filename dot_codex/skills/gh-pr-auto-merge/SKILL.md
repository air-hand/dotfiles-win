---
name: gh-pr-auto-merge
description: Finish a feature branch by reviewing local changes, running appropriate validation, committing, pushing, creating a GitHub pull request, and enabling squash auto-merge with branch deletion. Use when the user asks Codex to commit changes, create a PR, set auto-merge, squash merge, or delete the branch after merge.
---

# GitHub PR Auto Merge

## Overview

Use this workflow to turn the current feature branch into a pull request and set it to merge automatically once required checks pass.

## Workflow

1. Inspect the branch and worktree:
   - Run `git status --short --branch`.
   - Confirm the branch is not `main` or the repository's default branch before committing.
   - Review `git diff --stat` and relevant diffs so only intended files are included.

2. Validate before committing:
   - Run tests or linters appropriate to the changed files.
   - If validation cannot run, report that clearly before proceeding.
   - Do not skip existing project hooks or checks unless the user explicitly asks.

3. Commit:
   - Stage only intended files.
   - Use a concise conventional commit message when the repo uses that style.
   - Let commit hooks run normally.

4. Push:
   - Run `git push -u origin <branch>` for a new branch, or `git push` if upstream already exists.
   - If push fails because remote history moved, inspect the situation before rebasing or force-pushing.

5. Create the PR:
   - Use `gh pr create --base main --head <branch> --title "<title>" --body "<body>"`.
   - Include a short summary and validation results in the body.
   - If a PR already exists for the branch, reuse it instead of creating a duplicate.

6. Enable auto-merge:
   - Run `gh pr merge <number-or-url> --auto --squash --delete-branch`.
   - Verify with `gh pr view <number> --json autoMergeRequest,mergeStateStatus,statusCheckRollup,url`.
   - If auto-merge is blocked, report the blocking checks or review requirements.

## Guardrails

- Never commit unrelated or unreviewed worktree changes.
- Never run destructive git commands to clean up without explicit user approval.
- Prefer non-interactive `git` and `gh` commands.
- If branch deletion is requested, use GitHub's `--delete-branch` on merge; do not delete a local branch that is currently checked out.
- Finish with the commit SHA, PR URL, auto-merge status, and any checks still pending.
