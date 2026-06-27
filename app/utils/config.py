"""Environment-driven configuration. No secrets are ever hard-coded."""
from __future__ import annotations

import os
from dataclasses import dataclass
from functools import lru_cache

from dotenv import load_dotenv

load_dotenv(override=False)

DATABASE = os.getenv("SNOWFLAKE_DATABASE", "ANALYTICS_DB")
SCHEMA = os.getenv("SNOWFLAKE_SCHEMA", "PRESENTATION")
FQ_SCHEMA = f"{DATABASE}.{SCHEMA}"

# Curated presentation views exposed to the app.
VIEWS: list[str] = [
    "EXECUTIVE_KPI", "REVENUE_TREND", "SALES_COUNTRY_CATEGORY",
    "CUSTOMER_OVERVIEW", "CUSTOMER_KPI", "PRODUCT_OVERVIEW", "PRODUCT_KPI",
    "SALES_OVERVIEW", "RETURNS_REFUNDS_OVERVIEW", "INVENTORY_OVERVIEW",
    "STOCK_ALERTS_OVERVIEW", "MARKETING_OVERVIEW", "MARKETING_ATTRIBUTION_OVERVIEW",
    "DQ_OVERVIEW", "DQ_DOMAIN_OVERVIEW", "DQ_FAILURES_OVERVIEW",
    "AI_REVIEW_SENTIMENT", "AI_CUSTOMER_PROFILE", "AI_CAMPAIGN_INSIGHTS",
    "ENTERPRISE_SEARCH", "AI_COPILOT_CONTEXT",
]


@dataclass(frozen=True)
class SnowflakeConfig:
    account: str
    user: str
    private_key_path: str
    private_key_passphrase: str | None
    role: str
    warehouse: str
    database: str
    schema: str

    @property
    def is_complete(self) -> bool:
        return bool(self.account and self.user and self.private_key_path
                    and os.path.exists(self.private_key_path))


@lru_cache(maxsize=1)
def snowflake_config() -> SnowflakeConfig:
    return SnowflakeConfig(
        account=os.getenv("SNOWFLAKE_ACCOUNT", ""),
        user=os.getenv("SNOWFLAKE_USER", ""),
        private_key_path=os.getenv("SNOWFLAKE_PRIVATE_KEY_PATH", ""),
        private_key_passphrase=os.getenv("SNOWFLAKE_PRIVATE_KEY_PASSPHRASE") or None,
        role=os.getenv("SNOWFLAKE_ROLE", ""),
        warehouse=os.getenv("SNOWFLAKE_WAREHOUSE", ""),
        database=DATABASE,
        schema=SCHEMA,
    )


def openai_config() -> dict[str, str]:
    return {
        "api_key": os.getenv("OPENAI_API_KEY", ""),
        "model": os.getenv("OPENAI_MODEL", "gpt-4o-mini"),
    }


def openai_enabled() -> bool:
    return bool(openai_config()["api_key"])


def fq(view: str) -> str:
    return f"{FQ_SCHEMA}.{view}"
