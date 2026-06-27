"""Sales Analytics — performance + returns & refunds."""
from __future__ import annotations

import streamlit as st

from components.blocks import ai_summary, data_table, filter_bar
from components.charts import area, bar, donut, line, show, smart_chart
from components.theme import hero, section
from utils.data_provider import safe_load
from utils.frames import categorical_columns, datetime_columns, humanize, numeric_columns


def render() -> None:
    hero(
        "Sales Analytics",
        "Revenue momentum, channel performance and the cost of returns & refunds.",
        ["Sales", "Revenue", "Returns"],
    )

    tab_sales, tab_returns = st.tabs(["💰 Sales", "↩️ Returns & Refunds"])

    with tab_sales:
        df, err = safe_load("SALES_OVERVIEW")
        if err or df.empty:
            st.info("No sales data available.")
        else:
            filtered = filter_bar(df, key="sales")
            dates = datetime_columns(filtered)
            nums = numeric_columns(filtered)
            cats = [c for c in categorical_columns(filtered) if c not in dates]
            st.write("")
            if dates and nums:
                d = filtered.sort_values(dates[0])
                if cats and filtered[cats[0]].nunique() <= 8:
                    agg = d.groupby([dates[0], cats[0]], dropna=False)[nums[0]].sum().reset_index()
                    show(line(agg, x=dates[0], y=nums[0], color=cats[0],
                              title=f"{humanize(nums[0])} over time by {humanize(cats[0])}"))
                else:
                    agg = d.groupby(dates[0])[nums[0]].sum().reset_index()
                    show(area(agg, x=dates[0], y=nums[0], title=f"{humanize(nums[0])} over time"))
            if cats and nums:
                grp = filtered.groupby(cats[0], dropna=False)[nums[0]].sum().reset_index()
                grp = grp.sort_values(nums[0], ascending=False)
                show(bar(grp, x=cats[0], y=nums[0],
                         title=f"{humanize(nums[0])} by {humanize(cats[0])}"))
            ai_summary(filtered, "Sales overview",
                       "Call out momentum, seasonality and strongest channels.", key="sales")
            section("Sales detail")
            data_table(filtered, download_name="sales_overview")

    with tab_returns:
        rr, rerr = safe_load("RETURNS_REFUNDS_OVERVIEW")
        if rerr or rr.empty:
            st.info("No returns data available.")
        else:
            cats, nums = categorical_columns(rr), numeric_columns(rr)
            c1, c2 = st.columns(2)
            with c1:
                smart_chart(rr)
            with c2:
                if cats and nums:
                    grp = rr.groupby(cats[0], dropna=False)[nums[0]].sum().reset_index()
                    grp = grp.sort_values(nums[0], ascending=False)
                    if grp[cats[0]].nunique() <= 6:
                        show(donut(grp, names=cats[0], values=nums[0],
                                   title=f"Returns by {humanize(cats[0])}"))
                    else:
                        show(bar(grp, x=cats[0], y=nums[0],
                                 title=f"Returns by {humanize(cats[0])}"))
            data_table(rr, title="Returns detail", download_name="returns_refunds_overview")
            ai_summary(rr, "Returns & refunds",
                       "Quantify refund impact and flag problem categories.", key="returns")
