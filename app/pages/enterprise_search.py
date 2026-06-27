"""Enterprise Search over ANALYTICS_DB.PRESENTATION.ENTERPRISE_SEARCH."""
from __future__ import annotations

import streamlit as st

from components.blocks import data_table
from components.theme import hero, section
from utils.data_provider import enterprise_search
from utils.frames import categorical_columns
from utils.openai_client import summarize


def render() -> None:
    hero(
        "Enterprise Search",
        "Search across every domain indexed in the enterprise knowledge layer.",
        ["Search", "Cross-domain", "ENTERPRISE_SEARCH"],
    )

    col_q, col_n = st.columns([5, 1])
    with col_q:
        term = st.text_input(
            "Search", placeholder="Search customers, products, campaigns, orders, metrics…",
            label_visibility="collapsed",
        )
    with col_n:
        limit = st.selectbox("Results", [50, 100, 250, 500], index=1,
                             label_visibility="collapsed")

    # Quick chips
    st.caption("Try:")
    chips = st.columns(5)
    for i, q in enumerate(["Champions", "Electronics", "Paid Search", "Returned", "Revenue"]):
        if chips[i].button(q, key=f"chip_{i}", use_container_width=True):
            term = q

    if not term:
        st.info("Type a query to search the enterprise index.")
        return

    with st.spinner("Searching…"):
        try:
            results = enterprise_search(term, limit=int(limit))
        except Exception as exc:  # noqa: BLE001
            st.error("Search failed.")
            st.code(str(exc))
            return

    if results.empty:
        st.warning(f"No matches for **{term}**.")
        return

    st.success(f"Found **{len(results):,}** results for **{term}**.")

    # Facet by domain/entity if present
    facet = next((c for c in categorical_columns(results)
                  if any(k in c.lower() for k in ("domain", "entity", "type"))), None)
    if facet:
        counts = results[facet].astype(str).value_counts()
        st.markdown("  ".join(f"`{k}: {v}`" for k, v in counts.items()))

    with st.expander("✨ AI summary of results", expanded=True):
        with st.spinner("Summarising…"):
            st.markdown(summarize(results, f"Enterprise search results for '{term}'",
                                  "Summarise what these results collectively reveal."))

    section("Results")
    data_table(results, height=500, download_name=f"search_{term[:18]}")
