#!/usr/bin/env bash
set -euo pipefail

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  cat <<'EOF'
Usage:
  CODEX_HOME=/path/to/codex-home ./scripts/install-codex-skill.sh

Notes:
  - CODEX_HOME must be set explicitly.
  - This script installs via `npx skills add ...` first.
  - It then copies the installed skill into $CODEX_HOME/skills/mcp2cli for Codex.
EOF
  exit 0
fi

if [ -z "${CODEX_HOME:-}" ]; then
  echo "CODEX_HOME must be set explicitly." >&2
  echo "Example: CODEX_HOME=~/.rayplus-codex ./scripts/install-codex-skill.sh" >&2
  exit 1
fi

command -v npx >/dev/null 2>&1 || {
  echo "npx is required. Install Node.js first." >&2
  exit 1
}

TMP_HOME="$(mktemp -d)"
trap 'rm -rf "$TMP_HOME"' EXIT

HOME="$TMP_HOME" npx skills add yx4724201000subg/mcp2cli --skill mcp2cli --agent codex -g -y --copy

SOURCE_DIR="$TMP_HOME/.agents/skills/mcp2cli"
TARGET_DIR="$CODEX_HOME/skills/mcp2cli"

if [ ! -f "$SOURCE_DIR/SKILL.md" ]; then
  echo "npx install did not produce $SOURCE_DIR/SKILL.md" >&2
  exit 1
fi

mkdir -p "$CODEX_HOME/skills"
rm -rf "$TARGET_DIR"
mkdir -p "$TARGET_DIR"
cp -R "$SOURCE_DIR"/. "$TARGET_DIR"/

test -f "$TARGET_DIR/SKILL.md"
