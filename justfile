# Keel Data Stack Hub
set shell := ["bash", "-euo", "pipefail", "-c"]

default:
    @just --list

# Check all 17 Keel binaries on PATH
doctor:
    bash scripts/install.sh --doctor

# Install all 17 tools from source via cargo
install-cargo:
    bash scripts/install.sh --method cargo

# Install all 17 tools from GitHub Release wheels via uv
install-wheels:
    bash scripts/install.sh --method wheel

# Install all 17 bundled SKILL.md files into <dir> (default .agents/skills)
install-skills dir='.agents/skills':
    bash scripts/install-skills.sh "{{dir}}"

# Check latest GitHub Release tag and asset count across all 17 repos
check-releases:
    for tool in datakeel sqlkeel loadkeel fetchkeel runkeel dapkeel statkeel mapkeel pgkeel litekeel maskkeel sheetkeel auditkeel scorekeel driftkeel evalkeel textkeel; do \
        gh release view -R "robertguss/$tool" --json tagName,assets \
          --jq "\"$tool: \" + .tagName + \" (\" + (.assets | length | tostring) + \" assets)\""; \
    done
