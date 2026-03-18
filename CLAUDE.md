# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Workflow

This project uses **nbdev** — source code lives in Jupyter notebooks under `nbs/api/`, and Python files in `circadian/` are **auto-generated**. Never edit `circadian/*.py` directly.

```bash
# Install in editable mode
pip install -e .

# After editing notebooks, regenerate Python files, run tests, and validate
nbdev_prepare

# Run a single test notebook
nbdev_test --path nbs/test/test_models.ipynb
```

## Key Architecture Concepts

### Source of Truth: Notebooks
- `nbs/api/00_models.ipynb` through `nbs/api/10_synthetic_data.ipynb` — source code with docs
- `nbs/test/` — test notebooks (test_models, test_lights, test_metrics, test_readers, test_synthetic_data)
- `nbs/examples/` — usage examples

Use `#| export` to export a cell to the generated Python module. Use `#| hide` to exclude a cell from docs.

### Module Overview
| Module | Role |
|--------|------|
| `models.py` | Circadian ODE models (Forger99, Hannay19, Hannay19TP, Jewett99, Hilaire07, Breslow13, Skeldon23) integrated with RK4 |
| `lights.py` | Light schedule creation (constant, pulsed, shift-work, outdoor) |
| `sleep.py` | Sleep prediction and analysis (two-process model, sleep clustering) |
| `readers.py` | Wearable data readers (JSON, CSV, Actiwatch); exposes pandas DataFrame accessor |
| `metrics.py` | Circadian rhythm metrics |
| `prc.py` | Phase Response Curve tools, comparison against human data |
| `plots.py` | Visualization (actogram, phase plots, torus, stroboscopic) |
| `synthetic_data.py` | Generate synthetic activity data from light schedules |
| `utils.py` / `phasetools.py` | Phase calculations, time conversions, coherence measures |
| `cli.py` | CLI entry points (actogram, ESRI apps); uses `torch` for JIT |

### Skills
Prefer `.claude/skills/<name>/SKILL.md` over `.claude/commands/` for project slash commands. Available skills:
- `/fix-issue <number>` — fetch a GitHub issue and follow the full nbdev fix workflow

### CI/CD
- **test.yaml**: runs `nbdev_ci` on PRs and pushes
- **deploy.yaml**: builds Quarto docs and deploys to GitHub Pages on push to main
- **python-publish.yml**: publishes to PyPI on release
- **claude-code-review.yml** / **claude.yml**: Claude-powered review on PRs and issues
