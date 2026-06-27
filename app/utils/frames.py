"""Schema-agnostic dataframe profiling so the UI adapts to any view shape."""
from __future__ import annotations

import pandas as pd


def numeric_columns(df: pd.DataFrame) -> list[str]:
    return [c for c in df.columns if pd.api.types.is_numeric_dtype(df[c])]


def datetime_columns(df: pd.DataFrame) -> list[str]:
    out: list[str] = []
    for c in df.columns:
        if pd.api.types.is_datetime64_any_dtype(df[c]):
            out.append(c)
        elif df[c].dtype == object and any(
            k in c.lower() for k in ("date", "month", "day", "period", "time", "_at")
        ):
            out.append(c)
    return out


def categorical_columns(df: pd.DataFrame) -> list[str]:
    nums, dates = set(numeric_columns(df)), set(datetime_columns(df))
    out = []
    for c in df.columns:
        if c in nums or c in dates:
            continue
        if df[c].nunique(dropna=True) <= max(60, int(len(df) * 0.7)):
            out.append(c)
    return out


def text_columns(df: pd.DataFrame) -> list[str]:
    return [c for c in df.columns if df[c].dtype == object]


def coerce_dates(df: pd.DataFrame) -> pd.DataFrame:
    df = df.copy()
    for c in datetime_columns(df):
        if df[c].dtype == object:
            df[c] = pd.to_datetime(df[c], errors="coerce")
    return df


def humanize(name: str) -> str:
    return str(name).replace("_", " ").strip().title()


def kpi_records(df: pd.DataFrame) -> list[dict]:
    """Normalise a KPI view into [{label, value, delta}] for either long or wide shapes."""
    if df.empty:
        return []
    lower = {c.lower(): c for c in df.columns}
    label_col = next((lower[k] for k in ("metric", "kpi", "name", "label") if k in lower), None)
    value_col = next((lower[k] for k in ("value", "amount", "metric_value", "current") if k in lower), None)
    delta_col = next((lower[k] for k in ("delta", "change", "pct_change", "yoy", "mom", "vs_prev", "trend") if k in lower), None)

    records: list[dict] = []
    if label_col and value_col:
        for _, row in df.iterrows():
            records.append({
                "label": humanize(str(row[label_col])),
                "value": row[value_col],
                "delta": row[delta_col] if delta_col else None,
            })
    else:
        row = df.iloc[0]
        for c in numeric_columns(df):
            records.append({"label": humanize(c), "value": row[c], "delta": None})
    return records
