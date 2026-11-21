#!/usr/bin/env bash
set -euo pipefail

ALL_TOOLS=(
  datakeel
  sqlkeel
  loadkeel
  fetchkeel
  runkeel
  dapkeel
  statkeel
  mapkeel
  pgkeel
  litekeel
  maskkeel
  sheetkeel
  auditkeel
)

METHOD="cargo"
TOOLS_CSV=""
DOCTOR_ONLY=0

usage() {
  cat <<'EOF'
Usage: install.sh [OPTIONS]

Install or verify the 12-tool Rust Keel Data Stack.

Options:
  --method cargo|wheel   Install via `cargo install --git` (default) or prebuilt GitHub Release wheels (`uv tool install`).
  --tools t1,t2,...      Comma-separated subset of tools (defaults to all 12).
  --doctor               Check installed Keel binaries and print versions without installing.
  -h, --help             Show this help message.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --method)
      METHOD="${2:-}"
      shift 2
      ;;
    --tools)
      TOOLS_CSV="${2:-}"
      shift 2
      ;;
    --doctor)
      DOCTOR_ONLY=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

SELECTED=()
if [[ -n "$TOOLS_CSV" ]]; then
  IFS=',' read -r -a SELECTED <<< "$TOOLS_CSV"
else
  SELECTED=("${ALL_TOOLS[@]}")
fi

if [[ "$DOCTOR_ONLY" -eq 1 ]]; then
  missing=0
  for tool in "${SELECTED[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
      printf "✓ %-12s %s (%s)\n" "$tool" "$("$tool" --version 2>&1 | head -n1)" "$(command -v "$tool")"
    else
      printf "✖ %-12s NOT INSTALLED\n" "$tool"
      missing=$((missing + 1))
    fi
  done
  exit "$missing"
fi

case "$METHOD" in
  cargo)
    command -v cargo >/dev/null 2>&1 || { echo "error: cargo not found on PATH" >&2; exit 2; }
    for tool in "${SELECTED[@]}"; do
      echo "==> Installing $tool via cargo..."
      cargo install --git "https://github.com/robertguss/$tool" --locked
    done
    ;;
  wheel)
    command -v uv >/dev/null 2>&1 || { echo "error: uv not found on PATH (install uv or use --method cargo)" >&2; exit 2; }
    command -v gh >/dev/null 2>&1 || { echo "error: gh CLI not found on PATH (needed to resolve latest release assets)" >&2; exit 2; }

    os="$(uname -s)"
    arch="$(uname -m)"
    case "$os/$arch" in
      Linux/x86_64)   plat="manylinux2014_x86_64" ;;
      Linux/aarch64)  plat="manylinux2014_aarch64" ;;
      Darwin/arm64)   plat="macosx_11_0_arm64" ;;
      Darwin/x86_64)  plat="macosx_10_12_x86_64" ;;
      *)
        echo "error: unsupported platform $os/$arch for --method wheel; use --method cargo" >&2
        exit 2
        ;;
    esac

    for tool in "${SELECTED[@]}"; do
      echo "==> Installing $tool ($plat wheel)..."
      url="$(gh release view -R "robertguss/$tool" --json assets --jq ".assets[] | select(.name | contains(\"$plat\")) | .url" | head -n1)"
      if [[ -z "$url" ]]; then
        echo "error: no $plat wheel found in latest release of robertguss/$tool" >&2
        exit 1
      fi
      uv tool install --force "$url"
    done
    ;;
  *)
    echo "error: invalid --method '$METHOD' (expected 'cargo' or 'wheel')" >&2
    exit 2
    ;;
esac

echo ""
echo "Done! Installed Keel Data Stack binaries:"
for tool in "${SELECTED[@]}"; do
  if command -v "$tool" >/dev/null 2>&1; then
    printf "  ✓ %-12s %s\n" "$tool" "$("$tool" --version 2>&1 | head -n1)"
  fi
done
