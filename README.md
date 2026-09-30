# PT_Medallion — End-to-End Medallion Architecture on Snowflake

Medallion architecture (Bronze / Silver / Gold) built with **dbt** on **Snowflake**,
using the TPC-H SF1 benchmark dataset. Delivers a consumption-ready dimensional
model answering: *which customers and market segments are most profitable, and
how does that break down by region and over time?*

## Architecture

| Layer  | Schema | Purpose |
|--------|--------|---------|
| Bronze | `BRONZE` | Raw 1:1 copies of the TPC-H source tables. No transformations — preserves the original data for auditability and decouples the project from direct access to `SNOWFLAKE_SAMPLE_DATA`. |
| Silver | `SILVER` | Cleaned and conformed data: renamed columns, standardized status codes, calculated revenue metrics, and deduplication on natural/composite keys. |
| Gold   | `GOLD` | Consumption-ready star schema for the profitability use case: `gold_fact_sales` (line-item grain) plus `gold_dim_customer` and `gold_dim_date`. |

**Consumer:** Sales/commercial analysts, via Power BI, to identify which
customer segments and regions drive the most revenue.

## Tech stack

- **Snowflake** — data warehouse, source: `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1`
- **dbt Cloud** — transformations, testing, documentation, orchestration
- **GitHub** — version control, Pull Request-based workflow
- **Power BI** — BI consumption layer on top of the Gold schema

## Project structure

models/
├── bronze/
│ ├── sources.yml # source declarations pointing to TPCH_SF1
│ └── bronze.sql # 1:1 passthrough models
├── silver/
│ ├── silver_models.yml # tests + descriptions
│ └── silver_.sql # cleansed/conformed models
└── gold/
├── gold_models.yml # tests + descriptions
├── gold_dim_customer.sql
├── gold_dim_date.sql
└── gold_fact_sales.sql
macros/
├── generate_schema_name.sql # custom macro: schemas resolve to exactly bronze/silver/gold
└── test_unique_combination_of_columns.sql # custom generic test: composite-key uniqueness



## Setup

1. **Snowflake**: create a database (this project uses `PROPELLINGTECH_DB`) and confirm
   read access to `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1`.
2. **dbt Cloud**: create a project, connect it to this GitHub repository, and set up:
   - A **Development** connection (personal credentials, used while working in the IDE).
   - A **Production** deployment environment with its own connection profile
     (`Database: PROPELLINGTECH_DB`, `Schema: analytics` — actual per-layer schemas
     are resolved by the custom `generate_schema_name` macro to `BRONZE`/`SILVER`/`GOLD`).
3. **Jobs**:
   - `CI Checks` — Continuous Integration job, triggered on Pull Requests, runs `dbt build`.
   - `Production Build` — Deploy job against the Production environment, run manually or
     on a schedule; also serves as the state/manifest reference for CI's deferral.

## Running the project

```bash
dbt build            # runs models + tests, in dependency order
dbt build --select bronze
dbt build --select silver
dbt build --select gold
dbt test             # tests only
dbt docs generate     # generates the lineage graph / documentation
```

## Data quality

- **Generic tests**: `unique`, `not_null`, and `relationships` on primary/foreign keys
  across Silver and Gold.
- **Custom generic test** (`unique_combination_of_columns`): validates composite natural
  keys that dbt's built-in `unique` test cannot check on its own (e.g. `lineitem`'s real
  primary key is `(order_id, line_number)`, not a single column).
- **Custom macro** (`generate_schema_name`): overrides dbt's default schema-name
  concatenation so Bronze/Silver/Gold appear as clean, exact schema names in Snowflake
  instead of `<target_schema>_bronze`, etc.

## CI/CD

Every Pull Request automatically triggers a `dbt build` in an isolated environment
via dbt Cloud, checked against the Production environment's state (Slim CI). This
catches breaking changes and test failures before they reach the main branch —
no PR is merged without a passing build.

## Dashboard

Power BI connects directly to the `GOLD` schema (`gold_fact_sales`, `gold_dim_customer`,
`gold_dim_date`) with no additional transformation required — relationships are built
on `customer_id` and `date_id`.