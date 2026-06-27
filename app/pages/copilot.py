"""
AI Copilot — a ChatGPT-style assistant grounded in the Snowflake analytics layer.

Per question:
  1. Retrieve supporting context from AI_COPILOT_CONTEXT (+ ENTERPRISE_SEARCH).
  2. Ground an OpenAI chat completion on that context (streamed, ChatGPT-style).
  3. Show supporting table + auto-chart when useful.

Works without an OpenAI key too, via a grounded offline answer composer.
"""
from __future__ import annotations

import pandas as pd
import streamlit as st

from components.charts import smart_chart
from components.theme import hero
from utils.data_provider import copilot_context, enterprise_search, is_live
from utils.openai_client import is_enabled, stream_chat

SYSTEM_PROMPT = (
    "You are 'Cortex Copilot', an enterprise BI assistant for a retail/e-commerce "
    "company. Answer ONLY from the Snowflake context provided (ANALYTICS_DB.PRESENTATION). "
    "Be concise and executive-ready; cite real numbers from the context and bold key "
    "figures. If the context lacks the answer, say so and point to the relevant dashboard "
    "page. Use short paragraphs and bullet points. Never fabricate data."
)

SUGGESTIONS = [
    "What are our top revenue drivers?",
    "Which customer segments are most valuable?",
    "Any data quality issues I should worry about?",
    "Which marketing channel has the best ROAS?",
    "What inventory needs attention right now?",
]


def _retrieve(question: str) -> pd.DataFrame:
    try:
        ctx = copilot_context(question, limit=25)
        if not ctx.empty:
            return ctx
    except Exception:  # noqa: BLE001
        pass
    try:
        es = enterprise_search(question, limit=20)
        if not es.empty:
            return es
    except Exception:  # noqa: BLE001
        pass
    return pd.DataFrame()


def _context_md(df: pd.DataFrame) -> str:
    return ("No matching context rows were found."
            if df.empty else df.head(30).to_markdown(index=False))


def _offline_answer(question: str, ctx: pd.DataFrame) -> str:
    if ctx.empty:
        return ("I couldn't find supporting context for that. Try the dashboards or "
                "rephrase your question. _(Set `OPENAI_API_KEY` for full AI answers.)_")
    lines = [f"Here's what the analytics layer shows for **\"{question}\"**:", ""]
    text_cols = [c for c in ctx.columns if ctx[c].dtype == object]
    for _, row in ctx.head(6).iterrows():
        bits = [str(row[c]) for c in (text_cols[:3] or ctx.columns[:3])]
        lines.append("- " + " — ".join(b for b in bits if b and b != "nan"))
    lines.append("")
    lines.append("_Offline answer composed from retrieved context. "
                 "Set `OPENAI_API_KEY` for AI-written summaries._")
    return "\n".join(lines)


def _ensure_state() -> None:
    if "copilot_msgs" not in st.session_state:
        st.session_state.copilot_msgs = []


def _render_support(ctx: pd.DataFrame) -> None:
    if isinstance(ctx, pd.DataFrame) and not ctx.empty:
        with st.expander("📎 Supporting data", expanded=False):
            st.dataframe(ctx, use_container_width=True, hide_index=True)
            smart_chart(ctx)


def _answer(question: str) -> None:
    ctx = _retrieve(question)
    grounding = _context_md(ctx)

    st.session_state.copilot_msgs.append(
        {"role": "user", "content": question, "ctx": None})
    with st.chat_message("user"):
        st.markdown(question)

    history = [{"role": m["role"], "content": m["content"]}
               for m in st.session_state.copilot_msgs if m["role"] in ("user", "assistant")]
    model_messages = (
        [{"role": "system", "content": SYSTEM_PROMPT}] + history[-6:]
        + [{"role": "user", "content":
            f"Question: {question}\n\nSnowflake context:\n{grounding}"}]
    )

    with st.chat_message("assistant"):
        placeholder = st.empty()
        if is_enabled():
            full = ""
            try:
                for delta in stream_chat(model_messages, temperature=0.2, max_tokens=900):
                    full += delta
                    placeholder.markdown(full + "▌")
                placeholder.markdown(full)
            except Exception as exc:  # noqa: BLE001
                full = _offline_answer(question, ctx)
                placeholder.markdown(f"_AI error, showing grounded answer ({exc})._\n\n" + full)
        else:
            full = _offline_answer(question, ctx)
            placeholder.markdown(full)
        _render_support(ctx)

    st.session_state.copilot_msgs.append(
        {"role": "assistant", "content": full, "ctx": ctx})


def render() -> None:
    _ensure_state()
    hero(
        "AI Copilot",
        "Ask anything about the business — grounded in your Snowflake analytics layer.",
        ["GPT-powered" if is_enabled() else "Offline-capable", "Grounded", "AI_COPILOT_CONTEXT"],
    )

    if not is_enabled():
        st.info("💡 Running in **offline** mode — answers are composed from retrieved Snowflake "
                "context. Set `OPENAI_API_KEY` in `.env` for AI-written, streamed responses.")

    tb1, tb2 = st.columns([1, 5])
    with tb1:
        if st.button("🗑 Clear chat", use_container_width=True):
            st.session_state.copilot_msgs = []
            st.rerun()
    with tb2:
        st.caption(f"Context source: {'🟢 Snowflake (LIVE)' if is_live() else '🟡 Demo data'}")

    if not st.session_state.copilot_msgs:
        st.markdown("##### Try asking…")
        cols = st.columns(len(SUGGESTIONS))
        for i, s in enumerate(SUGGESTIONS):
            if cols[i].button(s, key=f"sugg_{i}", use_container_width=True):
                _answer(s)
                st.rerun()

    for msg in st.session_state.copilot_msgs:
        with st.chat_message(msg["role"]):
            st.markdown(msg["content"])
            if msg["role"] == "assistant":
                _render_support(msg.get("ctx"))

    prompt = st.chat_input("Ask the Copilot a business question…")
    if prompt:
        _answer(prompt)
        st.rerun()
