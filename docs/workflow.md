# Git workflow

Simple workflow suitable for a small class team.

## Branch rules

- **Do not** commit directly to `main` for shared work. Keep `main` stable and reviewable.
- **Do** create a **feature branch** for each task or logical change (e.g. `feature/bronze-config-docs`).

## Typical flow

1. **Update local `main`:** `git checkout main` and `git pull` (after the repo has a remote and commits).
2. **Branch:** `git checkout -b feature/your-task`.
3. **Commit** small, clear commits on the feature branch.
4. **Push** the branch and open a **Pull Request (PR)** into `main`.
5. **Review:** At least one teammate reviews (course policy may require more).
6. **Merge** after approval. Delete the feature branch when done.

## PR hygiene

- Describe **what** changed and **why** in the PR description.
- Link to issues or assignment items if your course uses them.
- For SQL or config changes, note any **manual steps** (e.g. “run in BigQuery after merge”).

## Conflicts

- Pull `main` into your feature branch regularly: `git checkout feature/your-task` then `git merge main` (or `git rebase main` if the team prefers rebasing).
- Resolve conflicts locally before merging the PR.
