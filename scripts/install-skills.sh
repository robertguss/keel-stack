#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="${1:-.agents/skills}"
mkdir -p "$TARGET_DIR"

# Tools whose `skill --install <dir>` creates `<dir>/<tool>/SKILL.md`
NESTED_TOOLS=(dapkeel statkeel mapkeel pgkeel litekeel auditkeel scorekeel)
# Tools whose `skill --install <dir>` writes `<dir>/SKILL.md` directly
DIRECT_TOOLS=(fetchkeel datakeel loadkeel sqlkeel runkeel maskkeel sheetkeel)

installed=0
skipped=0

for tool in "${NESTED_TOOLS[@]}"; do
  if command -v "$tool" >/dev/null 2>&1; then
    "$tool" skill --install "$TARGET_DIR" --format human
    installed=$((installed + 1))
  else
    echo "skip: $tool not found on PATH" >&2
    skipped=$((skipped + 1))
  fi
done

for tool in "${DIRECT_TOOLS[@]}"; do
  if command -v "$tool" >/dev/null 2>&1; then
    "$tool" skill --install "$TARGET_DIR/$tool" --format human
    installed=$((installed + 1))
  else
    echo "skip: $tool not found on PATH" >&2
    skipped=$((skipped + 1))
  fi
done

echo "Installed $installed Keel SKILL.md file(s) into $TARGET_DIR ($skipped skipped)."
