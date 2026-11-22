# Keel Data Stack Hub
set shell := ["bash", "-euo", "pipefail", "-c"]

default:
    @just --list

# Check all 18 Keel binaries on PATH
doctor:
    bash scripts/install.sh --doctor

# Install all 18 tools from source via cargo
install-cargo:
    bash scripts/install.sh --method cargo

# Install all 18 tools from GitHub Release wheels via uv
install-wheels:
    bash scripts/install.sh --method wheel

# Install all 18 bundled SKILL.md files into <dir> (default .agents/skills)
install-skills dir='.agents/skills':
    bash scripts/install-skills.sh {{quote(dir)}}

# Check latest GitHub Release tag and asset count across all 18 repos
check-releases:
    for tool in datakeel sqlkeel loadkeel fetchkeel runkeel dapkeel statkeel mapkeel pgkeel litekeel maskkeel sheetkeel auditkeel scorekeel driftkeel evalkeel textkeel feakeel; do \
        info="$(gh release view -R "robertguss/$tool" --json tagName,assets --jq '"\(.tagName) (\(.assets | length) assets)"' 2>/dev/null || echo 'no release')"; \
        printf "%s: %s\n" "$tool" "$info"; \
    done
