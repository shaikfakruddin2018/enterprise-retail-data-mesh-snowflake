"""
Unified data access: serves LIVE Snowflake data when configured & reachable,
otherwise realistic DEMO data — transparently, behind one API.
"""
from __future__ import annotations

import pandas as pd
import streamlit as st

from utils import mock_data
from utils.config import fq, snowflake_config
from utils.frames import coerce_dates, text_columns


@st.cache_data(ttl=300, show_spinner=False)
def data_source() -> str:
    """Decide once (cached) whether we're LIVE or DEMO."""
    cfg = snowflake_config()
    if not cfg.is_complete:
        return "DEMO"
    try:
        from utils.snowflake_client import test_connection
        ok, _ = test_connection()
        return "LIVE" if ok else "DEMO"
    except Exception:  # noqa: BLE001
        return "DEMO"


def is_live() -> bool:
    return data_source() == "LIVE"


@st.cache_data(ttl=600, show_spinner=False)
def load(view: str, limit: int | None = None) -> pd.DataFrame:
    """Load a presentation view as a DataFrame (live or demo)."""
    if is_live():
        try:
            from utils.snowflake_client import load_view
            df = load_view(view, limit=limit)
            if not df.empty:
                return coerce_dates(df)
        except Exception:  # noqa: BLE001 - fall back to demo data
            pass
    df = mock_data.generate(view)
    if limit:
        df = df.head(limit)
    return coerce_dates(df)


def safe_load(view: str, limit: int | None = None) -> tuple[pd.DataFrame, str | None]:
    try:
        return load(view, limit=limit), None
    except Exception as exc:  # noqa: BLE001
        return pd.DataFrame(), str(exc)


def _text_filter(df: pd.DataFrame, term: str) -> pd.DataFrame:
    if df.empty or not term.strip():
        return df
    cols = text_columns(df) or list(df.columns)
    mask = pd.Series(False, index=df.index)
    for c in cols:
        mask |= df[c].astype(str).str.contains(term, case=False, na=False)
    return df[mask]


def enterprise_search(term: str, limit: int = 100) -> pd.DataFrame:
    """Query ANALYTICS_DB.PRESENTATION.ENTERPRISE_SEARCH (live), else demo index."""
    if is_live():
        try:
            from utils.snowflake_client import run_query, view_columns
            cols = view_columns("ENTERPRISE_SEARCH")
            if not term.strip():
                return run_query(f"SELECT * FROM {fq('ENTERPRISE_SEARCH')} LIMIT {int(limit)}")
            text_cols = [c for c in cols if any(
                k in c.lower() for k in ("text", "content", "title", "name", "search",
                                         "desc", "label", "keyword", "tag"))] or cols
            like = " OR ".join([f"LOWER({c}::STRING) LIKE %s" for c in text_cols])
            params = tuple([f"%{term.lower()}%"] * len(text_cols))
            return run_query(
                f"SELECT * FROM {fq('ENTERPRISE_SEARCH')} WHERE {like} LIMIT {int(limit)}",
                params,
            )
        except Exception:  # noqa: BLE001
            pass
    return _text_filter(load("ENTERPRISE_SEARCH"), term).head(limit)


def copilot_context(term: str, limit: int = 25) -> pd.DataFrame:
    """Retrieve grounding rows from AI_COPILOT_CONTEXT (live), else demo context."""
    if is_live():
        try:
            from utils.snowflake_client import run_query, view_columns
            cols = view_columns("AI_COPILOT_CONTEXT")
            if term.strip():
                text_cols = [c for c in cols if any(
                    k in c.lower() for k in ("text", "content", "context", "name",
                                             "title", "summary", "metric", "topic",
                                             "keyword"))] or cols
                like = " OR ".join([f"LOWER({c}::STRING) LIKE %s" for c in text_cols])
                params = tuple([f"%{term.lower()}%"] * len(text_cols))
                df = run_query(
                    f"SELECT * FROM {fq('AI_COPILOT_CONTEXT')} WHERE {like} LIMIT {int(limit)}",
                    params,
                )
                if not df.empty:
                    return df
            return run_query(f"SELECT * FROM {fq('AI_COPILOT_CONTEXT')} LIMIT {int(limit)}")
        except Exception:  # noqa: BLE001
            pass
    ctx = load("AI_COPILOT_CONTEXT")
    hit = _text_filter(ctx, term)
    return (hit if not hit.empty else ctx).head(limit)
