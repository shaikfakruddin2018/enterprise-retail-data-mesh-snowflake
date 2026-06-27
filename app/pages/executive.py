"""Executive Dashboard — the command centre."""
from __future__ import annotations

import streamlit as st

from components.blocks import ai_summary, data_table
from components.charts import area, bar, donut, line, show
from components.kpi import kpi_grid
from components.theme import hero, section
from utils.data_provider import safe_load
from utils.frames import (
    categorical_columns,
    datetime_columns,
    humanize,
    kpi_records,
    numeric_columns,
)


def render() -> None:
    hero(
        "Executive Dashboard",
        "A single pane of glass across revenue, customers, products and operations — "
        "powered by the ANALYTICS_DB.PRESENTATION layer.",
        ["Executive", "Real-time", "C-Suite"],
    )

    # KPIs with sparklines derived from the revenue trend
    kpi_df, _ = safe_load("EXECUTIVE_KPI")
    trend, _ = safe_load("REVENUE_TREND")
    sparks = {}
    if not trend.empty:
        nums = numeric_columns(trend)
        if "REVENUE" in trend.columns:
            sparks["Total Revenue"] = trend["REVENUE"].tolist()
        if "ORDERS" in trend.columns:
            sparks["Orders"] = trend["ORDERS"].tolist()
        if nums:
            sparks.setdefault("Gross Margin", trend[nums[-1]].tolist())
    section("Key performance indicators")
    kpi_grid(kpi_records(kpi_df), sparks=sparks, max_cards=8)

    st.write("")
    # Revenue trend + mix
    c1, c2 = st.columns([2, 1])
    with c1:
        section("Revenue trend")
        if trend.empty:
            st.info("No revenue trend available.")
        else:
            dcol = (datetime_columns(trend) or [trend.columns[0]])[0]
            nums = numeric_columns(trend)
            d = trend.sort_values(dcol)
            show(area(d, x=dcol, y=nums[0], title=None))
    with c2:
        section("Revenue mix")
        sc, _ = safe_load("SALES_COUNTRY_CATEGORY")
        if sc.empty:
            st.info("No category data.")
        else:
            cats, nums = categorical_columns(sc), numeric_columns(sc)
            cat = next((c for c in cats if "categ" in c.lower()), cats[0])
            grp = sc.groupby(cat, dropna=False)[nums[0]].sum().reset_index()
            grp = grp.sort_values(nums[0], ascending=False).head(8)
            show(donut(grp, names=cat, values=nums[0]))

    st.write("")
    section("Sales by country & category")
    sc, _ = safe_load("SALES_COUNTRY_CATEGORY")
    if not sc.empty:
        cats, nums = categorical_columns(sc), numeric_columns(sc)
        country = next((c for c in cats if "countr" in c.lower()), cats[0])
        cat = next((c for c in cats if "categ" in c.lower()), cats[-1])
        g1, g2 = st.columns(2)
        with g1:
            grp = sc.groupby(country, dropna=False)[nums[0]].sum().reset_index()
            grp = grp.sort_values(nums[0], ascending=False).head(12)
            show(bar(grp, x=country, y=nums[0],
                     title=f"{humanize(nums[0])} by {humanize(country)}"))
        with g2:
            top = sc.groupby([country, cat], dropna=False)[nums[0]].sum().reset_index()
            color = cat if sc[cat].nunique() <= 8 else None
            show(bar(top, x=country, y=nums[0], color=color, barmode="stack",
                     title=f"{humanize(nums[0])} by {humanize(country)} & {humanize(cat)}"))

        st.write("")
        ai_summary(sc, "Executive sales performance",
                   "Focus on the strongest and weakest countries and categories.", key="exec")
        section("Country / category detail")
        data_table(sc, height=320, download_name="sales_country_category")
