"""Premium enterprise design system: palette, global CSS, hero, sections, badges."""
from __future__ import annotations

import streamlit as st

# ── Design tokens ───────────────────────────────────────────────
PRIMARY = "#6366F1"      # indigo
PRIMARY_2 = "#8B5CF6"    # violet
ACCENT = "#22D3EE"       # cyan
SUCCESS = "#34D399"
WARNING = "#FBBF24"
DANGER = "#F87171"
BG = "#0A0C14"
PANEL = "#12151F"
PANEL_2 = "#171B27"
TEXT = "#E8ECF4"
MUTED = "#94A1B8"

PALETTE = ["#6366F1", "#22D3EE", "#34D399", "#FBBF24", "#F87171",
           "#8B5CF6", "#EC4899", "#38BDF8", "#FB923C", "#A3E635"]


def inject_css() -> None:
    st.markdown(
        f"""
        <style>
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;600&display=swap');

        html, body, [class*="css"] {{ font-family: 'Inter', sans-serif; }}
        .stApp {{
            background:
              radial-gradient(1200px 600px at 88% -8%, rgba(99,102,241,0.16), transparent 55%),
              radial-gradient(1000px 600px at -8% 4%, rgba(34,211,238,0.10), transparent 55%),
              {BG};
            color: {TEXT};
        }}
        .block-container {{ padding-top: 1.4rem; padding-bottom: 3rem; max-width: 1520px; }}
        h1,h2,h3,h4 {{ letter-spacing:-0.02em; color:{TEXT}; }}

        /* Sidebar */
        section[data-testid="stSidebar"] {{
            background: linear-gradient(180deg, #0D1019 0%, #080A11 100%);
            border-right: 1px solid rgba(255,255,255,0.06);
        }}
        section[data-testid="stSidebar"] * {{ color: {TEXT}; }}

        /* Hero */
        .hero {{
            position:relative; overflow:hidden; border-radius:22px; padding:26px 30px;
            margin-bottom:20px; border:1px solid rgba(255,255,255,0.08);
            background:
              radial-gradient(600px 200px at 90% 0%, rgba(139,92,246,0.22), transparent 60%),
              linear-gradient(120deg, rgba(99,102,241,0.16), rgba(34,211,238,0.05));
        }}
        .hero h1 {{ margin:0; font-size:1.85rem; font-weight:800; }}
        .hero p {{ margin:8px 0 0; color:{MUTED}; font-size:0.98rem; max-width:760px; }}
        .pill {{ display:inline-block; padding:4px 12px; border-radius:999px; font-size:0.7rem;
                 font-weight:600; letter-spacing:0.04em; margin-right:7px;
                 background:rgba(99,102,241,0.18); color:#C4C9FF;
                 border:1px solid rgba(99,102,241,0.4); }}

        /* KPI cards */
        .kgrid {{ display:grid; grid-template-columns:repeat(auto-fit,minmax(195px,1fr)); gap:14px; }}
        .kcard {{
            position:relative; border-radius:18px; padding:18px 18px 14px;
            background: linear-gradient(160deg, {PANEL_2} 0%, {PANEL} 100%);
            border:1px solid rgba(255,255,255,0.07);
            box-shadow:0 8px 30px rgba(0,0,0,0.34);
            transition: transform .16s ease, border-color .16s ease, box-shadow .16s ease;
        }}
        .kcard:hover {{ transform:translateY(-3px); border-color:rgba(99,102,241,0.6);
                        box-shadow:0 12px 38px rgba(99,102,241,0.18); }}
        .klabel {{ font-size:0.74rem; color:{MUTED}; text-transform:uppercase;
                   letter-spacing:0.07em; font-weight:600; }}
        .kvalue {{ font-size:1.85rem; font-weight:800; margin-top:6px; line-height:1.05; }}
        .krow {{ display:flex; align-items:flex-end; justify-content:space-between; margin-top:8px; }}
        .kdelta {{ font-size:0.82rem; font-weight:700; }}
        .up {{ color:{SUCCESS}; }} .down {{ color:{DANGER}; }} .flat {{ color:{MUTED}; }}

        /* Section header */
        .shead {{ display:flex; align-items:center; gap:10px; margin:8px 0 4px; }}
        .shead .bar {{ width:4px; height:20px; border-radius:4px;
                       background:linear-gradient(180deg,{PRIMARY},{ACCENT}); }}
        .shead h3 {{ margin:0; font-size:1.12rem; }}

        /* Badges */
        .badge {{ display:inline-flex; align-items:center; gap:6px; padding:5px 11px;
                  border-radius:999px; font-size:0.74rem; font-weight:700; }}
        .badge-live {{ background:rgba(52,211,153,0.14); color:{SUCCESS};
                       border:1px solid rgba(52,211,153,0.4); }}
        .badge-demo {{ background:rgba(251,191,36,0.14); color:{WARNING};
                       border:1px solid rgba(251,191,36,0.4); }}
        .dot {{ height:8px; width:8px; border-radius:50%; background:currentColor;
                box-shadow:0 0 8px currentColor; }}

        /* Dataframes / tabs / chat */
        [data-testid="stDataFrame"] {{ border-radius:12px; overflow:hidden;
            border:1px solid rgba(255,255,255,0.06); }}
        .stTabs [data-baseweb="tab-list"] {{ gap:4px; }}
        .stTabs [data-baseweb="tab"] {{ border-radius:10px 10px 0 0; }}
        [data-testid="stChatMessage"] {{ background:{PANEL}; border:1px solid rgba(255,255,255,0.06);
            border-radius:16px; }}
        div[data-testid="stMetricValue"] {{ font-weight:800; }}

        #MainMenu, footer, header [data-testid="stToolbar"] {{ visibility:hidden; }}
        </style>
        """,
        unsafe_allow_html=True,
    )


def hero(title: str, subtitle: str, tags: list[str] | None = None) -> None:
    tag_html = "".join(f'<span class="pill">{t}</span>' for t in (tags or []))
    st.markdown(
        f'<div class="hero"><div style="margin-bottom:10px">{tag_html}</div>'
        f"<h1>{title}</h1><p>{subtitle}</p></div>",
        unsafe_allow_html=True,
    )


def section(title: str) -> None:
    st.markdown(f'<div class="shead"><div class="bar"></div><h3>{title}</h3></div>',
                unsafe_allow_html=True)


def source_badge(source: str) -> str:
    if source == "LIVE":
        return '<span class="badge badge-live"><span class="dot"></span>LIVE · Snowflake</span>'
    return '<span class="badge badge-demo"><span class="dot"></span>DEMO · Synthetic data</span>'
