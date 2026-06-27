"""KPI cards with inline SVG sparklines."""
from __future__ import annotations

import streamlit as st

from components.theme import ACCENT, PRIMARY
from utils.formatting import compact, delta_parts


def sparkline(series, width: int = 120, height: int = 30, color: str = PRIMARY) -> str:
    """Return an inline SVG sparkline from a numeric series."""
    vals = [float(v) for v in series if v is not None]
    if len(vals) < 2:
        return ""
    lo, hi = min(vals), max(vals)
    rng = (hi - lo) or 1.0
    n = len(vals)
    pts = [
        (i / (n - 1) * width, height - ((v - lo) / rng) * (height - 4) - 2)
        for i, v in enumerate(vals)
    ]
    path = " ".join(f"{'M' if i == 0 else 'L'}{x:.1f},{y:.1f}" for i, (x, y) in enumerate(pts))
    area = (f"M0,{height} " + " ".join(f"L{x:.1f},{y:.1f}" for x, y in pts)
            + f" L{width},{height} Z")
    gid = f"g{abs(hash(tuple(vals))) % 99999}"
    return (
        f'<svg width="{width}" height="{height}" viewBox="0 0 {width} {height}">'
        f'<defs><linearGradient id="{gid}" x1="0" y1="0" x2="0" y2="1">'
        f'<stop offset="0%" stop-color="{color}" stop-opacity="0.35"/>'
        f'<stop offset="100%" stop-color="{color}" stop-opacity="0"/></linearGradient></defs>'
        f'<path d="{area}" fill="url(#{gid})"/>'
        f'<path d="{path}" fill="none" stroke="{color}" stroke-width="2" '
        f'stroke-linecap="round" stroke-linejoin="round"/></svg>'
    )


def _card(label: str, value, delta=None, spark=None, accent: str = PRIMARY) -> str:
    val = compact(value)
    dtext, ddir = delta_parts(delta)
    delta_html = f'<span class="kdelta {ddir}">{dtext}</span>' if dtext else "<span></span>"
    spark_html = spark or ""
    return (
        f'<div class="kcard" style="border-top:2px solid {accent}33;">'
        f'<div class="klabel">{label}</div>'
        f'<div class="kvalue">{val}</div>'
        f'<div class="krow">{delta_html}{spark_html}</div></div>'
    )


def kpi_grid(records: list[dict], sparks: dict | None = None, max_cards: int = 8) -> None:
    if not records:
        st.info("No KPI metrics available.")
        return
    sparks = sparks or {}
    colors = [PRIMARY, ACCENT, "#34D399", "#FBBF24", "#F87171", "#8B5CF6", "#EC4899", "#38BDF8"]
    html = '<div class="kgrid">'
    for i, r in enumerate(records[:max_cards]):
        accent = colors[i % len(colors)]
        spark = sparks.get(r.get("label"))
        spark_svg = sparkline(spark, color=accent) if spark is not None else None
        html += _card(r.get("label", ""), r.get("value"), r.get("delta"), spark_svg, accent)
    html += "</div>"
    st.markdown(html, unsafe_allow_html=True)
