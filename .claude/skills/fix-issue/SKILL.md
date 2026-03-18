---
name: fix-issue
description: Fix a GitHub issue in this repository following the nbdev workflow
---

Fix GitHub issue **#$ARGUMENTS** in this repository.

Start by fetching the issue:
```
gh issue view $ARGUMENTS --repo Arcascope/circadian --json title,body
```

Then follow this workflow:

## Before writing any code

1. Read [CONTRIBUTING.md](../../CONTRIBUTING.md) — the full development workflow is there. Key points:
   - All source code lives in **Jupyter notebooks** under `nbs/api/` — never edit `.py` files directly
   - Tests live in notebooks under `nbs/test/`
   - Use `#| export` to mark cells for export
   - Run `nbdev_prepare` to generate `.py` files and validate notebooks

2. Create a branch:
   ```
   git checkout main && git pull upstream main && git checkout -b fix/issue-$ARGUMENTS
   ```

## Implementing the fix

3. Find the relevant notebook(s) in `nbs/api/` and make changes there
4. Follow the code style shown in CONTRIBUTING.md (type hints, docstrings, inline comments)

## Tests are mandatory

5. Add or update tests in the corresponding `nbs/test/` notebook — the issue is not considered fixed without tests
   - Use `fastcore` test utilities: `test_eq`, `test_fail`, `test_close`, etc.
   - Cover the main case, edge cases, and input validation

## Before committing

6. Run the full prepare + clean sequence:
   ```
   nbdev_export          # export notebooks to .py files
   pip install -e .      # reinstall so tests use new code
   nbdev_test            # run all tests
   nbdev_clean           # strip outputs and metadata (required by CI)
   ```
   All steps must complete with no errors. The reinstall step is critical — without it, tests may pass locally but fail in CI.

## Commit and PR

7. Stage and commit — include ALL files changed by `nbdev_prepare`:
   ```
   git add nbs/ circadian/ settings.ini
   git status  # verify nothing relevant is unstaged
   git commit -m "Fix: <issue title> (#$ARGUMENTS)"
   ```

8. Push and open a PR:
   ```
   git push -u origin fix/issue-$ARGUMENTS
   ```
   Create a PR with a descriptive body covering: summary, changes made, and tests added. Fill in the sections before creating.

Once the PR is created, share its URL.
