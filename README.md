# Code Sandbox

## Example:
```sh
./code-sandbox "$HOME/dev/proj1" "$HOME/dev/proj2"
```

## Plugins:
- [opencode-antigravity-auth](https://github.com/NoeFabris/opencode-antigravity-auth?tab=readme-ov-file#models)

## Notes:
- Each project mounts under `$HOME/<basename>`
- OpenCode config + auth are stored in named or local volumes
- uv cache is stored in a named volume
- `source .venv-docker/bin/activate && uv sync --active`
