"""
Cortex Analytics — Enterprise BI Dashboard & AI Copilot
=======================================================
A production-quality Streamlit app over the curated Snowflake presentation layer
ANALYTICS_DB.PRESENTATION, with a ChatGPT-style AI Copilot.

Runs in a polished DEMO mode (realistic synthetic data) out of the box, and
switches to LIVE Snowflake + OpenAI automatically once credentials are set.

Run:  streamlit run app.py
"""
from __future__ import annotations

import streamlit as st

from components.theme import inject_css, source_badge
from pages import (
    copilot,
    customer,
    data_quality,
    enterprise_search,
    executive,
    inventory,
    marketing,
    product,
    sales,
)
from utils.config import FQ_SCHEMA, openai_config, openai_enabled
from utils.data_provider import data_source

st.set_page_config(
    page_title="Cortex Analytics",
    page_icon="🧠",
    layout="wide",
    initial_sidebar_state="expanded",
)


def _build_nav():
    return st.navigation({
        "Overview": [
            st.Page(executive.render, title="Executive Dashboard",
                    icon="📊", url_path="executive", default=True),
        ],
        "Analytics": [
            st.Page(customer.render, title="Customer Analytics", icon="👥", url_path="customers"),
            st.Page(product.render, title="Product Analytics", icon="📦", url_path="products"),
            st.Page(sales.render, title="Sales Analytics", icon="💰", url_path="sales"),
            st.Page(inventory.render, title="Inventory Analytics", icon="🏬", url_path="inventory"),
            st.Page(marketing.render, title="Marketing Analytics", icon="📣", url_path="marketing"),
            st.Page(data_quality.render, title="Data Quality", icon="🧪", url_path="data-quality"),
        ],
        "Intelligence": [
            st.Page(enterprise_search.render, title="Enterprise Search", icon="🔎", url_path="search"),
            st.Page(copilot.render, title="AI Copilot", icon="🤖", url_path="copilot"),
        ],
    })


def _sidebar_header() -> None:
    with st.sidebar:
        st.markdown(
            """
            <div style="display:flex;align-items:center;gap:12px;margin:2px 0 8px;">
              <div style="font-size:1.8rem;filter:drop-shadow(0 0 10px #6366F1);">🧠</div>
              <div>
                <div style="font-weight:800;font-size:1.2rem;line-height:1;">Cortex</div>
                <div style="color:#94A1B8;font-size:0.7rem;letter-spacing:0.14em;">
                  ANALYTICS PLATFORM
                </div>
              </div>
            </div>
            """,
            unsafe_allow_html=True,
        )
        st.markdown(source_badge(data_source()), unsafe_allow_html=True)
        st.write("")


def _sidebar_footer() -> None:
    with st.sidebar:
        st.divider()
        ai_on = openai_enabled()
        st.markdown(
            f'<div style="font-size:0.8rem;color:#94A1B8;">'
            f'{"🟢" if ai_on else "🟡"} OpenAI · <code>{openai_config()["model"]}</code><br>'
            f'📚 Source · <code>{FQ_SCHEMA}</code></div>',
            unsafe_allow_html=True,
        )
        st.caption("© Cortex Analytics • Portfolio build")


def main() -> None:
    inject_css()
    _sidebar_header()
    nav = _build_nav()
    _sidebar_footer()
    try:
        nav.run()
    except Exception as exc:  # noqa: BLE001 - last-resort guard
        st.error("Something went wrong rendering this page.")
        with st.expander("Technical details"):
            st.exception(exc)


if __name__ == "__main__":
    main()
