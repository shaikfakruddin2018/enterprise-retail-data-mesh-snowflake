"""Inventory Analytics — stock position + replenishment alerts."""
from __future__ import annotations

import streamlit as st

from components.blocks import ai_summary, data_table, filter_bar
from components.charts import bar, show, smart_chart
from components.theme import hero, section
from utils.data_provider import safe_load
from utils.frames import categorical_columns, humanize, numeric_columns


def render() -> None:
    hero(
        "Inventory Analytics",
        "Monitor stock health and act on replenishment alerts before you stock out.",
        ["Inventory", "Stock", "Supply"],
    )

    tab_pos, tab_alerts = st.tabs(["📦 Stock position", "🚨 Stock alerts"])

    with tab_pos:
        df, err = safe_load("INVENTORY_OVERVIEW")
        if err or df.empty:
            st.info("No inventory data available.")
        else:
            filtered = filter_bar(df, key="inv")
            cats, nums = categorical_columns(filtered), numeric_columns(filtered)
            st.write("")
            c1, c2 = st.columns(2)
            with c1:
                smart_chart(filtered)
            with c2:
                if cats and nums:
                    grp = filtered.groupby(cats[0], dropna=False)[nums[0]].sum().reset_index()
                    grp = grp.sort_values(nums[0], ascending=False).head(15)
                    show(bar(grp, x=cats[0], y=nums[0],
                             title=f"{humanize(nums[0])} by {humanize(cats[0])}"))
            ai_summary(filtered, "Inventory overview",
                       "Highlight overstock and understock risks.", key="inv")
            section("Inventory detail")
            data_table(filtered, download_name="inventory_overview")

    with tab_alerts:
        al, aerr = safe_load("STOCK_ALERTS_OVERVIEW")
        if aerr or al.empty:
            st.success("No active stock alerts. 🎉")
        else:
            crit = 0
            if "STATUS" in al.columns:
                crit = int((al["STATUS"].astype(str).str.lower() == "critical").sum())
            cols = st.columns(3)
            cols[0].metric("Active alerts", f"{len(al):,}")
            cols[1].metric("Critical", f"{crit}")
            if "SEVERITY" in al.columns:
                cols[2].metric("Avg severity", f"{al['SEVERITY'].mean():.1f}")
            st.write("")
            cats, nums = categorical_columns(al), numeric_columns(al)
            if cats and nums:
                grp = al.groupby(cats[0], dropna=False)[nums[0]].sum().reset_index()
                grp = grp.sort_values(nums[0], ascending=False).head(15)
                show(bar(grp, x=cats[0], y=nums[0], title=f"Alerts by {humanize(cats[0])}"))
            data_table(al, title="Active alerts", height=420,
                       download_name="stock_alerts_overview")
            ai_summary(al, "Stock alerts",
                       "Prioritise the most urgent replenishment actions.", key="alerts")
