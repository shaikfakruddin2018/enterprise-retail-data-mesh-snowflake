"""Composable page blocks shared across analytics pages."""
from __future__ import annotations

import pandas as pd
import streamlit as st

from components.charts import bar, donut, show, smart_chart
from components.kpi import kpi_grid
from utils.data_provider import safe_load
from utils.frames import (
    categorical_columns,
    datetime_columns,
    humanize,
    kpi_records,
    numeric_columns,
)
from utils.openai_client import is_enabled, summarize


def kpi_block(view: str, max_cards: int = 8) -> None:
    df, err = safe_load(view)
    if err:
        st.error(f"Could not load {view}: {err}")
        return
    kpi_grid(kpi_records(df), max_cards=max_cards)


def data_table(df: pd.DataFrame, *, title: str | None = None, height: int = 360,
               download_name: str | None = None) -> None:
    if title:
        st.markdown(f"**{title}**")
    st.dataframe(df, use_container_width=True, hide_index=True, height=height)
    if download_name and not df.empty:
        st.download_button("⬇ Download CSV", df.to_csv(index=False).encode("utf-8"),
                           file_name=f"{download_name}.csv", mime="text/csv")


def ai_summary(df: pd.DataFrame, title: str, instruction: str = "", key: str = "") -> None:
    if df.empty:
        return
    label = "✨ Generate AI insight" if is_enabled() else "✨ Generate insight (offline)"
    if st.button(label, key=f"ai_{key}"):
        with st.spinner("Analysing…"):
            st.markdown(summarize(df, title, instruction))


def filter_bar(df: pd.DataFrame, key: str) -> pd.DataFrame:
    """Compact filters: date range + up to two category facets."""
    if df.empty:
        return df
    work = df.copy()
    dates = datetime_columns(work)
    cats = [c for c in categorical_columns(work) if work[c].nunique() <= 40]
    n_controls = max(1, bool(dates) + min(2, len(cats)))
    cols = st.columns(n_controls)
    idx = 0

    if dates:
        dcol = dates[0]
        series = pd.to_datetime(work[dcol], errors="coerce")
        valid = series.dropna()
        if not valid.empty:
            lo, hi = valid.min().date(), valid.max().date()
            with cols[idx]:
                rng = st.date_input(humanize(dcol), value=(lo, hi),
                                    min_value=lo, max_value=hi, key=f"dt_{key}")
            idx += 1
            if isinstance(rng, (list, tuple)) and len(rng) == 2:
                m = (series.dt.date >= rng[0]) & (series.dt.date <= rng[1])
                work = work[m.fillna(False)]

    for cat in cats[:2]:
        if idx >= len(cols):
            break
        opts = sorted(str(v) for v in work[cat].dropna().unique())
        with cols[idx]:
            chosen = st.multiselect(humanize(cat), opts, key=f"f_{key}_{cat}")
        idx += 1
        if chosen:
            work = work[work[cat].astype(str).isin(chosen)]
    return work


def dual_chart(df: pd.DataFrame) -> None:
    """Primary smart chart + a complementary breakdown by a second dimension."""
    nums = numeric_columns(df)
    dates = datetime_columns(df)
    cats = [c for c in categorical_columns(df) if c not in dates]
    left, right = st.columns(2)
    with left:
        smart_chart(df, prefer="area" if dates else None)
    with right:
        if cats and nums:
            cat = cats[1] if len(cats) > 1 else cats[0]
            grp = df.groupby(cat, dropna=False)[nums[0]].sum().reset_index()
            if 2 <= grp[cat].nunique() <= 6:
                show(donut(grp, names=cat, values=nums[0],
                           title=f"{humanize(nums[0])} by {humanize(cat)}"))
            else:
                grp = grp.sort_values(nums[0], ascending=False).head(12)
                show(bar(grp, x=cat, y=nums[0],
                         title=f"{humanize(nums[0])} by {humanize(cat)}"))
        else:
            smart_chart(df, prefer="bar")
