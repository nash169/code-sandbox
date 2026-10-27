---
name: uv-environment
description: Run, test, and install Python code in a uv-managed project using the agent-only `.venv-code` environment, leaving the user's `.venv` untouched. Use when working in a project with `pyproject.toml` and `uv.lock`.
---

# How to use UV Environment

The project is managed with uv. Dependencies are declared in `pyproject.toml` and pinned in `uv.lock`.

Run commands from the repository root. Create or synchronize the agent's environment without touching the user's environment:

```sh
UV_PROJECT_ENVIRONMENT=.venv-code uv sync --locked
```

Always run code in the uv env named `.venv-code`:

```sh
VIRTUAL_ENV=.venv-code uv run --active python <script>
```

Do not use the default `.venv` — it belongs to the user.
In particular, do not follow the README's plain `uv sync` / `.venv` activation instructions for agent work.
Do not update dependencies or regenerate `uv.lock` unless the task calls for it.

Check in `pyproject.toml` for the optional `gpu` flag.
Use it via `--extra gpu` with sync/run only when CUDA is available.
Do not assume a GPU is always available.
