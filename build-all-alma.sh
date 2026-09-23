#!/usr/bin/env bash
set -euo pipefail

# Build every Alma/Primo NDE view described by an env file in configs/.
# Example: configs/standard.env, configs/special-collections.env, configs/stacks.env

CONFIG_DIR="${CONFIG_DIR:-configs}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

shopt -s nullglob
configs=("$CONFIG_DIR"/*.env)
if (( ${#configs[@]} == 0 )); then
  echo "No environment files found in $CONFIG_DIR/" >&2
  exit 1
fi

for config in "${configs[@]}"; do
  echo
  echo "===== Building $(basename "$config") ====="
  ENV_FILE="$config" "$SCRIPT_DIR/package-alma.sh"
done

echo
echo "All Alma packages created under dist/"
