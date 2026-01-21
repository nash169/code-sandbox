# Usage:
#   ./run-opencode.sh /abs/path/to/proj1 [/abs/path/to/proj2 ...]
#
# Example:
#   ./run-opencode.sh "$HOME/dev/proj1" "$HOME/dev/proj2"
#
# Notes:
# - Each project mounts under /workspace/<basename>
# - OpenCode config + auth are stored in named volumes (persist across runs)
# - uv cache is stored in a named volume
