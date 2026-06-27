"""Customer Analytics."""
from __future__ import annotations

import streamlit as st

from components.blocks import ai_summary, data_table, dual_chart, filter_bar, kpi_block
from components.theme import hero, section
from utils.data_provider import safe_load


def render() -> None:
    hero(
        "Customer Analytics",
        "Segments, lifetime value, churn signals and AI-generated customer profiles.",
        ["Customers", "Segmentation", "LTV"],
    )
    section("Customer KPIs")
    kpi_block("CUSTOMER_KPI")
    st.write("")

    tab_overview, tab_profiles = st.tabs(["📊 Overview", "🧠 AI Profiles"])

    with tab_overview:
        df, err = safe_load("CUSTOMER_OVERVIEW")
        if err or df.empty:
            st.info("No customer data available.")
        else:
            filtered = filter_bar(df, key="cust")
            st.write("")
            dual_chart(filtered)
            st.write("")
            ai_summary(filtered, "Customer overview",
                       "Highlight high-value segments and churn risk.", key="cust")
            section("Customer detail")
            data_table(filtered, download_name="customer_overview")

    with tab_profiles:
        prof, perr = safe_load("AI_CUSTOMER_PROFILE", limit=500)
        if perr or prof.empty:
            st.info("No AI customer profiles available.")
        else:
            st.caption("AI-generated customer personas from the analytics layer.")
            data_table(prof, height=420, download_name="ai_customer_profile")
            ai_summary(prof, "AI customer profiles",
                       "Summarise the dominant personas and their needs.", key="cust_prof")
