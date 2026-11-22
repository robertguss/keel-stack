# ⚓ Keel Data Stack

[![CI](https://github.com/robertguss/keel-stack/actions/workflows/ci.yml/badge.svg)](https://github.com/robertguss/keel-stack/actions/workflows/ci.yml)
[![License: MIT OR Apache-2.0](https://img.shields.io/badge/license-MIT%20OR%20Apache--2.0-blue.svg)](#license)

**An 18-tool suite of single-binary, blazing-fast Rust CLIs for modern data engineering, proof-carrying SQL auditing, leak-free point-in-time feature stores, zero-Python ML scoring + TreeSHAP + drift + evaluation + local NLP, analytics trust, FERPA/PII scrubbing, Excel/spreadsheet workflows, and local-first SQLite/PostgreSQL pipelines — designed from day one for both Humans (DX) and AI Agents (AX).**

Zero JVM. Zero Common Lisp. Zero bloated Python ETL dependency trees. Every tool ships as a native binary (plus prebuilt cross-platform Python wheels on GitHub Releases) with identical ergonomics, exit codes, and a bundled `SKILL.md`.

---

## Architecture Overview

```mermaid
flowchart LR
    subgraph Sources
        API["REST APIs"]
        DAP["Canvas Data 2 (DAP)"]
        FILES["CSV / JSONL / Parquet / Excel"]
        LEGACY["SQLite / MySQL"]
    end

    subgraph Ingest["Ingest, Spreadsheets & Migrate"]
        FK["fetchkeel"]
        DKP["dapkeel"]
        SHK["sheetkeel"]
        LK["loadkeel"]
        PGK["pgkeel"]
        LTK["litekeel"]
    end

    subgraph Storage["Databases"]
        PG[("PostgreSQL")]
        SQ[("SQLite + FTS5")]
    end

    subgraph Quality["Contracts, Lineage, Trust & Privacy"]
        DTK["datakeel"]
        SQK["sqlkeel"]
        ADK["auditkeel"]
        MK["mapkeel"]
        STK["statkeel"]
        MSK["maskkeel"]
    end

    RK["runkeel (Parallel DAG Runner)"]

    API --> FK --> DTK --> LK --> PG
    DAP --> DKP --> PG
    FILES --> DTK
    FILES --> LTK --> SQ
    LEGACY --> PGK --> PG
    PG --> MK
    PG --> STK
    PG --> MSK
    SQ --> MK
    SQ --> STK
    SQ --> MSK
    SQK -.-> PG
    RK -.-> Ingest
    RK -.-> Quality
```

---

## The 18 Tools

| # | Tool | Replaces / Role | Key Commands | Repository |
|---:|---|---|---|---|
| 1 | **`runkeel`** | Zero-daemon parallel DAG pipeline runner | `run`, `plan --mermaid`, `history` | [robertguss/runkeel](https://github.com/robertguss/runkeel) |
| 2 | **`fetchkeel`** | Declarative REST API pagination extractor → JSONL | `fetch`, `plan`, `watermark` | [robertguss/fetchkeel](https://github.com/robertguss/fetchkeel) |
| 3 | **`dapkeel`** | Instructure Canvas Data 2 (`dap`) Rust CLI | `list`, `schema --to-contract odcs`, `initdb`, `syncdb` | [robertguss/dapkeel](https://github.com/robertguss/dapkeel) |
| 4 | **`datakeel`** | `datacontract-cli` — ODCS v3.2.0 contracts, validation, quarantine, codegen | `infer`, `check`, `diff`, `lint`, `codegen` | [robertguss/datakeel](https://github.com/robertguss/datakeel) |
| 5 | **`loadkeel`** | `pandas.to_sql` / ETL loaders — JSONL/CSV/Parquet → Postgres `COPY` + upsert | `load`, `plan`, `--evolve` | [robertguss/loadkeel](https://github.com/robertguss/loadkeel) |
| 6 | **`sqlkeel`** | Static Postgres SQL semantic bugs, lock safety, dbt/Jinja, column lineage | `check`, `lineage`, `schema` | [robertguss/sqlkeel](https://github.com/robertguss/sqlkeel) |
| 7 | **`statkeel`** | `ydata-profiling` HTML/agent EDA + join health + live SQL trust auditor (`--assert`, `--trace-key`) + drift diff | `profile`, `join`, `audit`, `compare` | [robertguss/statkeel](https://github.com/robertguss/statkeel) |
| 8 | **`mapkeel`** | `SchemaSpy` — zero-Java/Graphviz SVG & Mermaid ER + implicit FKs + schema diff | `map`, `edges`, `diff`, `init-contracts` | [robertguss/mapkeel](https://github.com/robertguss/mapkeel) |
| 9 | **`pgkeel`** | `pgloader` — zero-Lisp SQLite/MySQL/CSV/JSONL/Parquet → Postgres migrator | `plan`, `migrate`, `verify` | [robertguss/pgkeel](https://github.com/robertguss/pgkeel) |
| 10 | **`litekeel`** | `sqlite-utils` — SQLite ingest, `--alter`, `--flatten`, FTS5 BM25, `extract`, `transform` | `insert`, `upsert`, `enable-fts`, `search`, `extract`, `transform` | [robertguss/litekeel](https://github.com/robertguss/litekeel) |
| 11 | **`maskkeel`** | Deterministic, referentially-intact FERPA/PII scrubber (HMAC-SHA256, `text_redact`/JSONB, FK-coherent subsetting, Parquet, HTML receipts) | `scan`, `mask`, `verify` | [robertguss/maskkeel](https://github.com/robertguss/maskkeel) |
| 12 | **`sheetkeel`** | Rust Excel (`.xlsx`/`.xls`/`.xlsb`/`.ods`) Swiss-army CLI: inspect, `--unmerge`, export to CSV/JSONL/Parquet/SQLite, pack & diff | `inspect`, `export`, `pack`, `diff` | [robertguss/sheetkeel](https://github.com/robertguss/sheetkeel) |
| 13 | **`auditkeel`** | Proof-Carrying SQL Analysis Auditor: read-only Postgres CTE row waterfalls, join fan-out/coverage probes, grain spot-checks, live A/B query diff & HTML receipts | `run`, `check`, `diff`, `skill` | [robertguss/auditkeel](https://github.com/robertguss/auditkeel) |
| 14 | **`scorekeel`** | Zero-Python Pure-Rust LightGBM Scorer & Exact Lundberg TreeSHAP Explainer for CSV, JSONL, Parquet & HTTP sidecars | `inspect`, `score`, `serve`, `bench`, `skill` | [robertguss/scorekeel](https://github.com/robertguss/scorekeel) |
| 15 | **`driftkeel`** | Zero-Python Production ML Feature, Prediction & Concept Drift Monitor (PSI, KS, Jensen-Shannon, missingness spikes, calibration ECE & HTML receipts) | `snapshot`, `check`, `skill` | [robertguss/driftkeel](https://github.com/robertguss/driftkeel) |
| 16 | **`evalkeel`** | Model-Agnostic ML Backtest, Calibration, Conformal Coverage, Subgroup Fairness Parity & Tamper-Evident HTML Model Card Engine | `binary`, `regress`, `skill` | [robertguss/evalkeel](https://github.com/robertguss/evalkeel) |
| 17 | **`textkeel`** | Zero-Python, Zero-PII Local Rust TF-IDF (1,2)-Gram + Multinomial Logistic Text Classifier with Phrase Attribution & Offline Browser Playground Export | `train`, `classify`, `export-browser`, `skill` | [robertguss/textkeel](https://github.com/robertguss/textkeel) |
| 18 | **`feakeel`** | Leak-Free Point-in-Time ML Feature Store Compiler & Static Temporal Leakage Linter for PostgreSQL `LATERAL` Queries | `init`, `validate`, `compile`, `run`, `skill` | [robertguss/feakeel](https://github.com/robertguss/feakeel) |

---

## Shared DX + AX Contract

Every tool in the Keel Data Stack follows the same predictable contract:

1. **Dual-mode output (`--format auto|human|agent|json`):** Rich colorized tables on a TTY; clean, zero-ANSI, token-budgeted structured output when piped or called by an AI agent.
2. **Strict `stdout` / `stderr` separation:** `stdout` is pure data payloads; `stderr` carries progress and file-write notices only.
3. **Actionable error envelopes:** Stable error codes (`E_*`), concise failure counts, bounded sample rows, `fix_hint`, and `retryable` flags.
4. **Zero interactivity:** Never hangs on `[y/N]` prompts.
5. **Clean exit codes:** `0` = pass/clean · `1` = data/quality/audit/drift failure · `2` = I/O, connection, parse, or config error.
6. **Bundled `SKILL.md` (`<tool> skill`):** Every binary ships its own up-to-date agent skill ready for `.agents/skills/` (Claude Code, Codex, Cursor, Antigravity).

---

## Quick Install

### Install all 18 tools from GitHub Releases (prebuilt wheels via `uv` — no Rust compiler needed)
```bash
git clone https://github.com/robertguss/keel-stack
cd keel-stack
./scripts/install.sh --method wheel
```

### Or install from source with Cargo
```bash
./scripts/install.sh --method cargo
```

### Install a subset or verify your installation
```bash
./scripts/install.sh --method cargo --tools statkeel,mapkeel,maskkeel,sheetkeel,pgkeel,litekeel
./scripts/install.sh --doctor
```

### Install all 18 AI Agent `SKILL.md` files into any repo
```bash
./scripts/install-skills.sh /path/to/your-repo/.agents/skills
```

---

## Playbooks

### 1. Proof-Carrying AI Data Analysis (`mapkeel` + `statkeel`)
Give AI agents (and software engineers) compiler-like confidence on cross-source SQL:
```bash
# Orient on all schemas + discover implicit cross-schema joins
mapkeel map "$DATABASE_URL" --schema populi,canvas --format agent

# Profile an unfamiliar table (catches NEAR_UNIQUE_KEY fan-out traps & PII)
statkeel profile "${DATABASE_URL}#canvas.pseudonyms" --html profile.html

# Check cross-source join cardinality, orphans & key normalization fixes
statkeel join "${DATABASE_URL}#populi.students" "${DATABASE_URL}#canvas.pseudonyms" \
  --left-key person_id --right-key sis_user_id

# Audit any AI-written SQL query before trusting its numbers (strictly read-only!)
statkeel audit query.sql --db "$DATABASE_URL" --rules rules.toml --html trust-receipt.html

# Prove a refactored query returns identical rows
statkeel compare --db "$DATABASE_URL" \
  --baseline-query old.sql --candidate-query new.sql \
  --key person_id --fail-on-row-diff
```

### 2. Zero-Python Declarative Postgres Data Lake (`fetchkeel` + `dapkeel` + `datakeel` + `loadkeel` + `sqlkeel` + `runkeel`)
- Extract REST APIs (`fetchkeel`) and Canvas Data 2 (`dapkeel`)
- Validate & quarantine bad rows against ODCS v3.2.0 / TOML contracts (`datakeel`)
- Stream into Postgres via binary/CSV `COPY` + atomic `ON CONFLICT` upserts (`loadkeel`)
- Gate SQL views & column blast radius in CI (`sqlkeel`)
- Orchestrate parallel waves with retries and JSON audit logs (`runkeel`)

### 3. Zero-Lisp Database Migration to PostgreSQL (`pgkeel`)
```bash
pgkeel plan mysql://user:pass@host:3306/app --target-schema app --emit-sql migration.sql
pgkeel migrate mysql://user:pass@host:3306/app "$DATABASE_URL" --target-schema app --workers 4
pgkeel verify mysql://user:pass@host:3306/app "$DATABASE_URL" --target-schema app
```

### 4. Local-First Searchable SQLite & FTS5 Workbench (`litekeel`)
```bash
litekeel insert notes.db articles articles.jsonl --pk id --flatten --alter
litekeel enable-fts notes.db articles title body --tokenize porter --create-triggers
litekeel search notes.db articles "reformed covenant" --format jsonl
```

### 5. Deterministic, Referentially-Intact FERPA/PII Scrubbing (`maskkeel`)
```bash
maskkeel scan "$PROD_RO_URL" --schema populi,canvas --init-config mask.toml
export MASKKEEL_SALT="team-dev-fixture-secret"
maskkeel mask "$PROD_RO_URL" "$DEV_DB_URL" --config mask.toml --require-salt --schema populi,canvas
maskkeel verify "$PROD_RO_URL" "$DEV_DB_URL" --config mask.toml --schema populi,canvas
```

### 6. Zero-Python Production ML Lifecycle (`feakeel` + `auditkeel` + `scorekeel` + `driftkeel` + `evalkeel` + `textkeel`)
```bash
# 1. Lint & compile leak-free point-in-time Postgres LATERAL features + auditkeel rules
feakeel validate features.toml --format agent
feakeel compile features.toml --mode live --out panel.sql --emit-audit-rules audit.toml
auditkeel run panel.sql --dsn "$PROD_RO_URL" --key student_id,term_id --format agent
feakeel run features.toml --dsn "$PROD_RO_URL" --mode live --out live_batch.jsonl

# 2. Check live feature & prediction drift before scoring (exit 1 on shift)
driftkeel check baseline.json live_batch.jsonl --html drift_receipt.html

# 3. Score LightGBM models with exact Lundberg TreeSHAP in pure Rust (or HTTP sidecar)
scorekeel score retention_lgbm.txt live_batch.jsonl --shap --top-k 3 --out scored.jsonl
scorekeel serve retention_lgbm.txt --bind 127.0.0.1:8080 --shap

# 4. Evaluate calibration, Top-K lift, conformal coverage & subgroup fairness
evalkeel binary oof_preds.parquet --y had_dfw --p risk_prob --group program --html model_card.html

# 5. Zero-PII local text classification & offline browser playground export
textkeel train notes.csv --text note_text --label category --out notes.tk.json --export-browser playground.html
```

---

## License

Dual-licensed under [MIT](LICENSE-MIT) or [Apache-2.0](LICENSE-APACHE), at your option.
