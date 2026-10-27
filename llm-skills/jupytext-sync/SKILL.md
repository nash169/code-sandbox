---
name: jupytext-sync
description: "Keep jupytext-paired `.py` scripts and `.ipynb` notebooks in sync. Use when editing Python scripts that declare jupytext notebook pairing (`formats: ipynb,py:percent`)."
---

# Jupytext Sync

The scripts declare notebook pairing via jupytext (`formats: ipynb,py:percent`).
Edit the `.py` file, preserve cell markers and metadata, then keep the pair in sync from the project's Python environment:

```sh
jupytext --sync <script.py>
```

If the `uv-environment` skill is active, run it through the agent's uv environment instead:

```sh
VIRTUAL_ENV=.venv-code uv run --active jupytext --sync <script.py>
```

Never edit the `.py` and `.ipynb` versions divergently.
Notebooks are ignored by `.gitignore`; the `.py` files are the version-controlled source.
Do not force-add generated notebooks unless explicitly requested.
