"""Product Analytics."""
from __future__ import annotations

import streamlit as st

from components.blocks import ai_summary, data_table, filter_bar, kpi_block
from components.charts import bar, scatter, show, smart_chart
from components.theme import hero, section
from utils.data_provider import safe_load
from utils.frames import categorical_columns, humanize, numeric_columns


def render() -> None:
    hero(
        "Product Analytics",
        "Performance, margins, top sellers and AI-derived review sentiment.",
        ["Products", "Margin", "Sentiment"],
    )
    section("Product KPIs")
    kpi_block("PRODUCT_KPI")
    st.write("")

    tab_overview, tab_sentiment = st.tabs(["📊 Overview", "💬 Review Sentiment"])

    with tab_overview:
        df, err = safe_load("PRODUCT_OVERVIEW")
        if err or df.empty:
            st.info("No product data available.")
        else:
            filtered = filter_bar(df, key="prod")
            nums, cats = numeric_columns(filtered), categorical_columns(filtered)
            st.write("")
            c1, c2 = st.columns(2)
            with c1:
                label = next((c for c in cats if "product" in c.lower()), cats[0]) if cats else None
                if label and nums:
                    grp = filtered.groupby(label, dropna=False)[nums[0]].sum().reset_index()
                    grp = grp.sort_values(nums[0], ascending=False).head(12)
                    show(bar(grp, x=nums[0], y=label, orientation="h",
                             title=f"Top {humanize(label)} by {humanize(nums[0])}"))
                else:
                    smart_chart(filtered)
            with c2:
                if len(nums) >= 2:
                    color = next((c for c in cats if "categ" in c.lower()), None)
                    show(scatter(filtered, x=nums[0], y=nums[1],
                                 size=nums[2] if len(nums) > 2 else None,
                                 color=color if color and filtered[color].nunique() <= 8 else None,
                                 hover=cats[0] if cats else None,
                                 title=f"{humanize(nums[1])} vs {humanize(nums[0])}"))
                else:
                    smart_chart(filtered, prefer="bar")
            st.write("")
            ai_summary(filtered, "Product overview",
                       "Identify best/worst performers and margin concerns.", key="prod")
            section("Product detail")
            data_table(filtered, download_name="product_overview")

    with tab_sentiment:
        sent, serr = safe_load("AI_REVIEW_SENTIMENT", limit=1000)
        if serr or sent.empty:
            st.info("No review sentiment data available.")
        else:
            nums, cats = numeric_columns(sent), categorical_columns(sent)
            c1, c2 = st.columns(2)
            with c1:
                smart_chart(sent)
            with c2:
                if cats and nums:
                    grp = sent.groupby(cats[0], dropna=False)[nums[0]].mean().reset_index()
                    grp = grp.sort_values(nums[0], ascending=False).head(12)
                    show(bar(grp, x=nums[0], y=cats[0], orientation="h",
                             title=f"{humanize(nums[0])} by {humanize(cats[0])}"))
            data_table(sent, title="Review sentiment detail", height=380,
                       download_name="ai_review_sentiment")
            ai_summary(sent, "AI review sentiment",
                       "Summarise overall sentiment and top praise/complaint themes.",
                       key="sentiment")
