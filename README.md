# Code Sandbox

Code Sandbox builds and runs a disposable Docker development container with optional tools such as CUDA, uv, opencode, Claude Code, Codex, and LaTeX.

## Requirements

- `Docker`
- `whiptail`, used by the first-run installer prompt
- `uuidgen`, used to generate container names

## Usage

Run the sandbox with one or more project directories:

```sh
./code-sandbox <path/to/folder/1> <path/to/folder/2> ...
```

The first time you run an image name, the script opens an interactive prompt where you choose which tools to install.
It then builds the Docker image.
If the image already exists, the script skips the build and starts a container from that image.

Use `-i` or `--image` to select a specific image name.
This is useful if you have multiple sandbox images, such as `my-cpu-sandbox` and `my-gpu-sandbox`.

```sh
./code-sandbox -i <image-name> <path/to/folder/1> <path/to/folder/2> ...
```

Show help:

```sh
./code-sandbox --help
```

## Install Choices

On first run for a new image, you can choose any combination of:

- `cuda`: NVIDIA CUDA support
- `uv`: Python package and virtual environment tooling
- `opencode`: opencode CLI
- `claude-code`: Claude Code CLI
- `codex`: OpenAI Codex CLI
- `latex`: full LaTeX installation

If you select CUDA, you can specify the release version by setting the env var `CUDA_TAG` in `.env` before building.
The Docker base image is built as `nvidia/cuda:${CUDA_TAG}-devel-ubuntu24.04`.

## Mount Layout

- The container starts in `/workspace`.
- `WORKSPACE` from `.env` is mounted at `/workspace`.
- If `WORKSPACE` is empty, the script creates a temporary host directory under `/tmp/code_sandbox_workspace-*` and mounts it at `/workspace`.
- Each project path passed on the command line is mounted at `/home/ubuntu/<folder-name>`.
- Project paths must be directories.
- Two project paths with the same folder name are rejected to avoid mount collisions.

## Persistent Volumes

Persistent paths are mounted only when the matching tool is installed in the image.
The `.env` file controls the host path or Docker volume name used for each mount.
If a value is empty, Docker creates or reuses the default named volume from the script.

### uv

- `~/.config/uv`
- `~/.local/share/uv`
- `~/.cache/uv`

### opencode

- `~/.config/opencode`
- `~/.local/share/opencode`
- `~/.cache/opencode`

### claude-code

- `~/.claude`
- `~/.cache/claude`

### codex

- `~/.codex`

## Auth Callback Port

When opencode or Codex is installed, the script maps an auth callback port from the host to the container.
It starts at `127.0.0.1:1455` and increments if that port is already used by another sandbox container.

## Sources

- To check available options for the `opencode.json` see [config.json](https://opencode.ai/config.json)
- In case you want to implement something like the `llm-wiki` idea, run `code-sanbox` specifying the path to your wiki folder. copy the generic [guidelines](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) into the llm prompt followed by something like:

  ```
  You are now my LLM WiKi agent. Implement this idea. Create the CLAUDE.md schema file with full rules, set up index.md and log.md, define folder conventions. From now on, every interaction follows the schema.
  ```
