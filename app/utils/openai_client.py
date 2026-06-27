"""OpenAI wrapper for the Copilot and inline summaries, with graceful fallback."""
from __future__ import annotations

from functools import lru_cache

from utils.config import openai_config, openai_enabled


@lru_cache(maxsize=1)
def _client():
    from openai import OpenAI
    cfg = openai_config()
    if not cfg["api_key"]:
        raise RuntimeError("OPENAI_API_KEY not set")
    return OpenAI(api_key=cfg["api_key"])


def is_enabled() -> bool:
    return openai_enabled()


def chat(messages: list[dict], *, temperature: float = 0.2, max_tokens: int = 900,
         model: str | None = None) -> str:
    cfg = openai_config()
    resp = _client().chat.completions.create(
        model=model or cfg["model"], messages=messages,
        temperature=temperature, max_tokens=max_tokens,
    )
    return resp.choices[0].message.content or ""


def stream_chat(messages: list[dict], *, temperature: float = 0.2,
                max_tokens: int = 900, model: str | None = None):
    cfg = openai_config()
    stream = _client().chat.completions.create(
        model=model or cfg["model"], messages=messages,
        temperature=temperature, max_tokens=max_tokens, stream=True,
    )
    for chunk in stream:
        delta = chunk.choices[0].delta.content
        if delta:
            yield delta


def summarize(df, title: str, instruction: str = "") -> str:
    """Executive narrative for a dataframe (works with or without an API key)."""
    if df is None or df.empty:
        return "_No data available to summarise._"
    sample = df.head(40).to_markdown(index=False)
    if not is_enabled():
        return _offline_summary(df, title)
    prompt = (
        f"You are a senior BI analyst. Summarise the dataset '{title}'.\n{instruction}\n\n"
        "Give 3-5 concise, executive-ready bullets with specific numbers from the data. "
        "Highlight trends, outliers and clear actions. Never invent values.\n\n"
        f"Data (first rows):\n{sample}"
    )
    try:
        return chat(
            [{"role": "system", "content": "You are a precise, concise BI analyst."},
             {"role": "user", "content": prompt}],
            temperature=0.3, max_tokens=420,
        )
    except Exception as exc:  # noqa: BLE001
        return f"_AI summary unavailable ({exc})._\n\n" + _offline_summary(df, title)


def _offline_summary(df, title: str) -> str:
    """Deterministic rule-based summary used when OpenAI is not configured."""
    import pandas as pd

    lines = [f"**{title} — quick read** _(offline summary; set `OPENAI_API_KEY` for AI narratives)_"]
    nums = [c for c in df.columns if pd.api.types.is_numeric_dtype(df[c])]
    cats = [c for c in df.columns if df[c].dtype == object]
    lines.append(f"- Dataset spans **{len(df):,} rows** across **{len(df.columns)} fields**.")
    if cats and nums:
        cat, measure = cats[0], nums[0]
        top = df.groupby(cat)[measure].sum().sort_values(ascending=False)
        if len(top):
            lines.append(f"- Top **{cat.replace('_',' ').title()}** by "
                         f"{measure.replace('_',' ').title()}: **{top.index[0]}** "
                         f"({top.iloc[0]:,.0f}).")
            if len(top) > 1:
                lines.append(f"- Lowest: **{top.index[-1]}** ({top.iloc[-1]:,.0f}).")
    for c in nums[:2]:
        lines.append(f"- **{c.replace('_',' ').title()}** — total {df[c].sum():,.0f}, "
                     f"avg {df[c].mean():,.1f}.")
    return "\n".join(lines)
