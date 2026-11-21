# AGENTS.md — Choosing the Right Keel Data Stack Tool

Always pass `--format agent` (or `--format json`) when calling any Keel CLI programmatically.

| Task | Tool to Use |
|---|---|
| Orient on an unfamiliar Postgres or SQLite DB, generate SVG/Mermaid ER docs, discover implicit cross-schema joins, or diff two schema snapshots | **`mapkeel`** (`map`, `edges`, `diff`, `init-contracts`) |
| Profile CSV/Parquet/JSONL/SQLite/Postgres data, check join cardinality/fan-out/normalization, audit AI-written SQL live, or compare two query results | **`statkeel`** (`profile`, `join`, `audit`, `compare`) |
| Validate data files/tables against ODCS v3.2.0 or TOML contracts, split quarantine rows, diff contracts, or generate Postgres/Pydantic code | **`datakeel`** (`infer`, `check`, `diff`, `lint`, `codegen`) |
| Lint SQL files offline for semantic bugs, schema grounding, Postgres migration lock safety, or column-level blast radius | **`sqlkeel`** (`check`, `lineage`, `schema`) |
| Extract paginated REST APIs into JSONL with incremental watermarks | **`fetchkeel`** (`fetch`, `plan`) |
| Sync Instructure Canvas Data 2 (DAP) tables into PostgreSQL or export ODCS schemas | **`dapkeel`** (`list`, `schema`, `initdb`, `syncdb`, `listdb`) |
| Bulk-load JSONL/CSV/Parquet into PostgreSQL via `COPY` + atomic `ON CONFLICT` upserts | **`loadkeel`** (`load`, `plan`) |
| Migrate an entire SQLite, MySQL/MariaDB database, or folder of files into PostgreSQL | **`pgkeel`** (`plan`, `migrate`, `verify`) |
| Ingest JSON/JSONL/CSV/Parquet into SQLite, build FTS5 BM25 search, extract lookup tables, or transform SQLite schemas | **`litekeel`** (`insert`, `upsert`, `enable-fts`, `search`, `extract`, `transform`, `analyze`, `optimize`) |
| Orchestrate multi-step pipelines with parallel waves, retries, `--from` resume, and JSON audit logs | **`runkeel`** (`run`, `plan`, `history`) |
