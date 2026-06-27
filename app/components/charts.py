"""Themed Plotly charts + a schema-agnostic smart_chart()."""
from __future__ import annotations

import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
import streamlit as st

from components.theme import PALETTE
from utils.frames import (
    categorical_columns,
    datetime_columns,
    humanize,
    numeric_columns,
)

_LAYOUT = dict(
    template="plotly_dark",
    paper_bgcolor="rgba(0,0,0,0)",
    plot_bgcolor="rgba(0,0,0,0)",
    font=dict(color="#E8ECF4", family="Inter, sans-serif", size=13),
    margin=dict(l=8, r=8, t=46, b=8),
    colorway=PALETTE,
    legend=dict(bgcolor="rgba(0,0,0,0)", orientation="h", y=-0.18),
    title=dict(font=dict(size=15)),
    hoverlabel=dict(bgcolor="#171B27", bordercolor="#6366F1"),
)


def _style(fig: go.Figure, title: str | None = None) -> go.Figure:
    fig.update_layout(**_LAYOUT)
    if title:
        fig.update_layout(title=title)
    fig.update_xaxes(showgrid=False, zeroline=False)
    fig.update_yaxes(gridcolor="rgba(255,255,255,0.06)", zeroline=False)
    return fig


def line(df, x, y, title=None, color=None):
    fig = px.line(df, x=x, y=y, color=color, markers=True)
    fig.update_traces(line=dict(width=2.8))
    return _style(fig, title)


def area(df, x, y, title=None):
    fig = px.area(df, x=x, y=y)
    fig.update_traces(line=dict(width=2.4), fillcolor="rgba(99,102,241,0.18)")
    return _style(fig, title)


def bar(df, x, y, title=None, color=None, orientation="v", barmode="group"):
    fig = px.bar(df, x=x, y=y, color=color, orientation=orientation, barmode=barmode)
    fig.update_traces(marker_line_width=0)
    return _style(fig, title)


def donut(df, names, values, title=None):
    fig = px.pie(df, names=names, values=values, hole=0.62)
    fig.update_traces(textposition="inside", textinfo="percent+label")
    return _style(fig, title)


def scatter(df, x, y, size=None, color=None, title=None, hover=None):
    fig = px.scatter(df, x=x, y=y, size=size, color=color, size_max=42, hover_name=hover)
    return _style(fig, title)


_chart_seq = 0


def show(fig: go.Figure, key: str | None = None) -> None:
    """Render a Plotly figure with a guaranteed-unique key (avoids ID collisions)."""
    global _chart_seq
    _chart_seq += 1
    st.plotly_chart(
        fig, use_container_width=True, config={"displayModeBar": False},
        key=key or f"plot_{_chart_seq}",
    )


def smart_chart(df: pd.DataFrame, title: str | None = None, prefer: str | None = None) -> None:
    """Pick the most fitting visualisation for an arbitrary dataframe."""
    if df is None or df.empty:
        st.info("No data to visualise.")
        return
    dates = datetime_columns(df)
    nums = numeric_columns(df)
    cats = [c for c in categorical_columns(df) if c not in dates]

    if not nums:
        st.dataframe(df, use_container_width=True, hide_index=True)
        return
    measure = nums[0]

    if dates and prefer in (None, "line", "area"):
        d = df.sort_values(dates[0])
        color = cats[0] if cats and df[cats[0]].nunique() <= 8 else None
        if color:
            show(line(d, x=dates[0], y=measure, color=color,
                      title=title or f"{humanize(measure)} over time"))
        else:
            show(area(d, x=dates[0], y=measure, title=title or f"{humanize(measure)} over time"))
        return

    if cats:
        cat = cats[0]
        grp = df.groupby(cat, dropna=False)[measure].sum().reset_index()
        grp = grp.sort_values(measure, ascending=False).head(15)
        if prefer == "donut" or (2 <= grp[cat].nunique() <= 6 and prefer != "bar"):
            show(donut(grp, names=cat, values=measure,
                       title=title or f"{humanize(measure)} by {humanize(cat)}"))
        else:
            show(bar(grp, x=cat, y=measure,
                     title=title or f"{humanize(measure)} by {humanize(cat)}"))
        return

    if len(nums) >= 2:
        show(scatter(df, x=nums[0], y=nums[1], size=nums[2] if len(nums) > 2 else None,
                     title=title or f"{humanize(nums[1])} vs {humanize(nums[0])}"))
        return

    st.dataframe(df, use_container_width=True, hide_index=True)
