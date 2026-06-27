"""Marketing Analytics — performance, attribution and AI campaign insights."""
from __future__ import annotations

import streamlit as st

from components.blocks import ai_summary, data_table, filter_bar
from components.charts import bar, donut, scatter, show, smart_chart
from components.theme import hero, section
from utils.data_provider import safe_load
from utils.frames import categorical_columns, humanize, numeric_columns


def render() -> None:
    hero(
        "Marketing Analytics",
        "Channel performance, ROAS, attribution and AI-generated campaign insights.",
        ["Marketing", "ROAS", "Attribution"],
    )

    tab_perf, tab_attr, tab_ai = st.tabs(
        ["📈 Performance", "🎯 Attribution", "🧠 AI Insights"]
    )

    with tab_perf:
        df, err = safe_load("MARKETING_OVERVIEW")
        if err or df.empty:
            st.info("No marketing data available.")
        else:
            filtered = filter_bar(df, key="mkt")
            cats, nums = categorical_columns(filtered), numeric_columns(filtered)
            st.write("")
            c1, c2 = st.columns(2)
            with c1:
                if cats and nums:
                    grp = filtered.groupby(cats[0], dropna=False)[nums[0]].sum().reset_index()
                    grp = grp.sort_values(nums[0], ascending=False)
                    show(bar(grp, x=cats[0], y=nums[0],
                             title=f"{humanize(nums[0])} by {humanize(cats[0])}"))
                else:
                    smart_chart(filtered)
            with c2:
                roas = next((c for c in nums if "roas" in c.lower()), None)
                spend = next((c for c in nums if "spend" in c.lower()), None)
                if roas and spend and cats:
                    show(scatter(filtered, x=spend, y=roas, size=spend, color=cats[0],
                                 hover=cats[0], title="ROAS vs Spend by channel"))
                elif cats and nums:
                    grp = filtered.groupby(cats[0], dropna=False)[nums[0]].sum().reset_index()
                    show(donut(grp, names=cats[0], values=nums[0],
                               title=f"{humanize(nums[0])} share"))
            ai_summary(filtered, "Marketing performance",
                       "Identify best-performing channels and ROI outliers.", key="mkt")
            section("Channel detail")
            data_table(filtered, download_name="marketing_overview")

    with tab_attr:
        at, aerr = safe_load("MARKETING_ATTRIBUTION_OVERVIEW")
        if aerr or at.empty:
            st.info("No attribution data available.")
        else:
            cats, nums = categorical_columns(at), numeric_columns(at)
            if cats and nums:
                grp = at.groupby(cats[0], dropna=False)[nums[0]].sum().reset_index()
                grp = grp.sort_values(nums[0], ascending=False)
                show(bar(grp, x=cats[0], y=nums[0],
                         title=f"Attributed {humanize(nums[0])} by {humanize(cats[0])}"))
            else:
                smart_chart(at)
            data_table(at, title="Attribution detail",
                       download_name="marketing_attribution_overview")
            ai_summary(at, "Marketing attribution",
                       "Explain which channels drive conversions across the journey.", key="attr")

    with tab_ai:
        ins, ierr = safe_load("AI_CAMPAIGN_INSIGHTS", limit=500)
        if ierr or ins.empty:
            st.info("No AI campaign insights available.")
        else:
            st.caption("AI-generated insights & recommendations per campaign.")
            data_table(ins, height=420, download_name="ai_campaign_insights")
            ai_summary(ins, "AI campaign insights",
                       "Synthesise recurring themes and recommended next actions.", key="camp")
