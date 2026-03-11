#!/bin/bash
# issue-prompt.sh — Generate a Claude Code prompt for fixing a GitHub issue
#
# Usage:
#   ./issue-prompt.sh <issue-number>
#
# Prints the prompt to stdout. Pipe to clipboard with:
#   ./issue-prompt.sh <issue-number> | pbcopy
# Then paste into Claude Code chat in VSCode.
#
# Requirements:
#   - GitHub CLI (gh): brew install gh  &&  gh auth login
#   - Python 3: brew install python
#   - nbdev 2.4.14: pip install "nbdev==2.4.14"
#   - Active Python venv with circadian installed in editable mode: pip install -e .
#   - numpy (latest): pip install -U numpy  (must match CI to catch numpy 2.x bugs locally)

ISSUE_NUM=${1:?Usage: ./issue-prompt.sh <issue-number>}

ISSUE_DATA=$(gh issue view "$ISSUE_NUM" --json title,body)
ISSUE_TITLE=$(echo "$ISSUE_DATA" | python3 -c "import sys,json; print(json.load(sys.stdin)['title'])")
ISSUE_BODY=$(echo "$ISSUE_DATA" | python3 -c "import sys,json; print(json.load(sys.stdin)['body'])")

cat <<EOF
Please fix GitHub issue **#${ISSUE_NUM}: ${ISSUE_TITLE}**.

**Issue description:**
${ISSUE_BODY}

## Before writing any code

1. Read [CONTRIBUTING.md](CONTRIBUTING.md) — it contains the full development workflow for this project. The most important points are:
   - All source code lives in **Jupyter notebooks** under \`nbs/api/\` — never edit the \`.py\` files directly, they are auto-generated
   - Tests live in notebooks under \`nbs/test/\`
   - Use \`#| export\` at the top of cells to mark them for export
   - Run \`nbdev_prepare\` from the repo root to generate \`.py\` files and validate all notebooks

2. Create a branch:
   \`\`\`
   git checkout main && git pull origin main && git checkout -b fix/issue-${ISSUE_NUM}
   \`\`\`

## Implementing the fix

3. Find the relevant notebook(s) in \`nbs/api/\` and make your changes there
4. Follow the code style and documentation conventions shown in CONTRIBUTING.md (type hints, docstrings, inline comments)

## Tests are mandatory

5. Add or update tests in the corresponding \`nbs/test/\` notebook. **The issue is not considered fixed without tests.**
   - Use \`fastcore\` test utilities: \`test_eq\`, \`test_fail\`, \`test_close\`, etc.
   - Cover the main case, edge cases, and any input validation
   - See CONTRIBUTING.md for test examples

## Before committing

6. Run the full prepare + clean sequence from the repo root:
   \`\`\`
   nbdev_export          # export notebooks to .py files
   pip install -e .      # reinstall package so tests use the new code
   nbdev_test            # run all tests against the freshly installed code
   nbdev_clean           # strip cell outputs and metadata (required by CI)
   \`\`\`
   All steps must complete with no errors. **The reinstall step is critical — without it, tests may silently run against old code and pass locally but fail in CI.**

## Commit and PR

7. Stage and commit — make sure to include ALL files changed by \`nbdev_prepare\`:
   \`\`\`
   git add nbs/ circadian/ settings.ini
   git status  # verify nothing relevant is unstaged
   git commit -m "Fix: ${ISSUE_TITLE} (#${ISSUE_NUM})"
   \`\`\`

8. Push and open a PR with a descriptive body:
   \`\`\`
   git push -u origin fix/issue-${ISSUE_NUM}
   gh pr create --title "Fix: ${ISSUE_TITLE}" --base main --body "\$(cat <<'PRBODY'
   ## Summary

   Fixes #${ISSUE_NUM}

   ## Changes

   <!-- Brief description of what was changed and why -->

   ## Tests

   <!-- Describe the tests added/updated in nbs/test/ -->

   ## Checklist

   - [ ] Changes made in notebooks under nbs/ (not .py files)
   - [ ] Tests added/updated in nbs/test/
   - [ ] nbdev_prepare runs successfully
   PRBODY
   )"
   \`\`\`
   Fill in the **Changes** and **Tests** sections with what you actually did before creating the PR.

Once the PR is created, share its URL.
EOF
