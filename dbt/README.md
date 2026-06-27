# Snowflake Data Mesh dbt Project

Enterprise-style retail/e-commerce Data Mesh on Snowflake.

## Layers
- Central RAW source database: `DATAMESH_DB`
- Domain marts: customer, product, sales, inventory, marketing
- Cross-domain analytics: `ANALYTICS_DB.RETAIL_ANALYTICS`
- DQ views: `DATA_QUALITY_DB.DQ`
- AI fallback/Cortex-ready products: `AI_DATA_PRODUCTS_DB.CORTEX_AI`

## Run
```bash
dbt debug
dbt deps
dbt run
dbt test
dbt docs generate
dbt docs serve
```

## Recommended run order
```bash
dbt run --select staging
dbt run --select silver
dbt run --select marts
dbt test
```
