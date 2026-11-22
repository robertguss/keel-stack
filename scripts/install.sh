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
  scorekeel
  driftkeel
  evalkeel
  textkeel
  feakeel
)

METHOD="cargo"
TOOLS_CSV=""
DOCTOR_ONLY=0

usage() {
  cat <<'EOF'
Usage: install.sh [OPTIONS]

Install or verify the 18-tool Rust Keel Data Stack.

Options:
  --method cargo|wheel   Install via `cargo install --git` (default) or prebuilt GitHub Release wheels (`uv tool install`).
  --tools t1,t2,...      Comma-separated subset of tools (defaults to all 18).
  --doctor               Check installed Keel binaries and print versions without installing.
  -h, --help             Show this help message.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --method)
      if [[ $# -lt 2 || -z "$2" || "$2" == -* ]]; then
        echo "error: --method requires a value ('cargo' or 'wheel')" >&2
        usage >&2
        exit 2
      fi
      METHOD="$2"
      shift 2
      ;;
    --tools)
      if [[ $# -lt 2 || -z "$2" || "$2" == -* ]]; then
        echo "error: --tools requires a comma-separated list of Keel tools" >&2
        usage >&2
        exit 2
      fi
      TOOLS_CSV="$2"
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

if [[ "${#SELECTED[@]}" -eq 0 ]]; then
  echo "error: no Keel tools selected" >&2
  exit 2
fi

# Strictly validate every requested tool name against the allowlist before
# executing any command, cargo install URL, or GitHub release lookup.
for tool in "${SELECTED[@]}"; do
  valid=0
  for allowed in "${ALL_TOOLS[@]}"; do
    if [[ "$tool" == "$allowed" ]]; then
      valid=1
      break
    fi
  done
  if [[ "$valid" -ne 1 ]]; then
    echo "error: unknown Keel tool '$tool'" >&2
    exit 2
  fi
done

if [[ "$DOCTOR_ONLY" -eq 1 ]]; then
  missing=0
  for tool in "${SELECTED[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
      ver="$("$tool" --version 2>&1 || true)"
      ver="${ver%%$'\n'*}"
      printf "✓ %-12s %s (%s)\n" "$tool" "$ver" "$(command -v "$tool")"
    else
      printf "✖ %-12s NOT INSTALLED\n" "$tool"
      missing=$((missing + 1))
    fi
  done
  if [[ "$missing" -eq 0 ]]; then
    exit 0
  fi
  exit 1
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
      Linux/x86_64)   plat_label="linux-x86_64"; plat_re='manylinux.*_x86_64[.]whl$' ;;
      Linux/aarch64)  plat_label="linux-aarch64"; plat_re='manylinux.*_aarch64[.]whl$' ;;
      Darwin/arm64)   plat_label="macos-arm64"; plat_re='macosx_.*_(arm64|universal2)[.]whl$' ;;
      Darwin/x86_64)  plat_label="macos-x86_64"; plat_re='macosx_.*_(x86_64|universal2)[.]whl$' ;;
      *)
        echo "error: unsupported platform $os/$arch for --method wheel; use --method cargo" >&2
        exit 2
        ;;
    esac

    for tool in "${SELECTED[@]}"; do
      echo "==> Installing $tool ($plat_label wheel)..."
      if ! url="$(gh release view -R "robertguss/$tool" --json assets --jq "first(.assets[] | select(.name | test(\"$plat_re\")) | .url) // empty")"; then
        echo "error: failed to query latest GitHub Release for robertguss/$tool" >&2
        exit 1
      fi
      if [[ -z "$url" ]]; then
        echo "error: no $plat_label wheel found in latest release of robertguss/$tool" >&2
        exit 1
      fi
      if [[ "$url" != https://github.com/robertguss/* ]]; then
        echo "error: unexpected release asset URL for $tool: $url" >&2
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
    ver="$("$tool" --version 2>&1 || true)"
    ver="${ver%%$'\n'*}"
    printf "  ✓ %-12s %s\n" "$tool" "$ver"
  fi
done
