"""Data Quality — health scores, per-domain breakdown and failing checks."""
from __future__ import annotations

import streamlit as st

from components.blocks import ai_summary, data_table, kpi_block
from components.charts import bar, donut, show, smart_chart
from components.theme import hero, section
from utils.data_provider import safe_load
from utils.frames import categorical_columns, humanize, numeric_columns


def render() -> None:
    hero(
        "Data Quality",
        "Trust the numbers — monitor data health, domain coverage and failing checks.",
        ["Governance", "Reliability", "Observability"],
    )
    section("Quality KPIs")
    kpi_block("DQ_OVERVIEW")
    st.write("")

    tab_domain, tab_fail = st.tabs(["🗂️ By domain", "❌ Failures"])

    with tab_domain:
        dom, derr = safe_load("DQ_DOMAIN_OVERVIEW")
        if derr or dom.empty:
            st.info("No domain-level metrics.")
        else:
            cats, nums = categorical_columns(dom), numeric_columns(dom)
            c1, c2 = st.columns(2)
            with c1:
                if cats and nums:
                    score = next((c for c in nums if "score" in c.lower()), nums[0])
                    grp = dom.groupby(cats[0], dropna=False)[score].mean().reset_index()
                    grp = grp.sort_values(score, ascending=False)
                    show(bar(grp, x=cats[0], y=score,
                             title=f"{humanize(score)} by {humanize(cats[0])}"))
                else:
                    smart_chart(dom)
            with c2:
                fails = next((c for c in nums if "fail" in c.lower()), None)
                if cats and fails:
                    grp = dom.groupby(cats[0], dropna=False)[fails].sum().reset_index()
                    show(donut(grp, names=cats[0], values=fails,
                               title=f"{humanize(fails)} share"))
            section("Domain detail")
            data_table(dom, download_name="dq_domain_overview")
            ai_summary(dom, "Data quality by domain",
                       "Flag the weakest domains and likely root causes.", key="dq_dom")

    with tab_fail:
        fail, ferr = safe_load("DQ_FAILURES_OVERVIEW", limit=1000)
        if ferr or fail.empty:
            st.success("No data quality failures recorded. 🎉")
        else:
            sev_col = next((c for c in fail.columns if "sever" in c.lower()), None)
            crit = 0
            if sev_col:
                crit = int(fail[sev_col].astype(str).str.lower().isin(["critical", "high"]).sum())
            cols = st.columns(3)
            cols[0].metric("Failing checks", f"{len(fail):,}")
            cols[1].metric("Critical / High", f"{crit}")
            nums = numeric_columns(fail)
            if nums:
                cols[2].metric("Failed records", f"{int(fail[nums[0]].sum()):,}")
            st.write("")
            cats = categorical_columns(fail)
            if cats:
                count_col = nums[0] if nums else None
                if count_col:
                    grp = fail.groupby(cats[0], dropna=False)[count_col].sum().reset_index()
                else:
                    grp = fail.groupby(cats[0], dropna=False).size().reset_index(name="count")
                    count_col = "count"
                grp = grp.sort_values(count_col, ascending=False).head(15)
                show(bar(grp, x=cats[0], y=count_col, title=f"Failures by {humanize(cats[0])}"))
            data_table(fail, title="Failure detail", height=400,
                       download_name="dq_failures_overview")
            ai_summary(fail, "Data quality failures",
                       "Group failures by theme and recommend remediation.", key="dq_fail")
