# 🧠 Cortex Analytics — Enterprise BI Dashboard & AI Copilot

A production-quality, portfolio-ready **Streamlit** application over the curated
Snowflake presentation layer **`ANALYTICS_DB.PRESENTATION`**, featuring **9
dashboards** and a **ChatGPT-style AI Copilot** grounded in your own data.

Built with **Streamlit · Plotly · Pandas · Snowflake (key-pair auth) · OpenAI**.

> **Runs out of the box.** With no credentials, Cortex serves a polished **DEMO**
> experience on realistic synthetic data. Add your `.env` and it automatically
> switches to **LIVE** Snowflake + OpenAI — the sidebar badge shows which mode
> you're in. Perfect for portfolios *and* production.

---

## ✨ Highlights

- 🎨 **Premium design system** — glassmorphic KPI cards with **inline SVG sparklines**,
  cohesive indigo/cyan theme, grouped sidebar navigation (`st.navigation`).
- 🔁 **Live ↔ Demo data provider** — one API serves Snowflake when reachable,
  realistic synthetic data otherwise. Never a blank or broken screen.
- 🤖 **AI Copilot** — ChatGPT-style streaming chat, **grounded** in
  `AI_COPILOT_CONTEXT`, with supporting tables/charts. Falls back to a grounded
  offline composer when no OpenAI key is present.
- 🔎 **Enterprise Search** over `ENTERPRISE_SEARCH` with domain facets + AI summary.
- 📊 **Schema-agnostic charts** — visuals auto-adapt to whatever columns each view
  returns, so it works on the demo data *and* your real views.
- ✨ **On-demand AI insights** on every page (OpenAI, or a deterministic offline summary).
- 🔐 **Key-pair Snowflake auth**, parameterised queries, secrets only from env vars.

---

## 📦 Pages

| Page | Views used |
|------|-----------|
| 📊 Executive Dashboard | `EXECUTIVE_KPI`, `REVENUE_TREND`, `SALES_COUNTRY_CATEGORY` |
| 👥 Customer Analytics | `CUSTOMER_KPI`, `CUSTOMER_OVERVIEW`, `AI_CUSTOMER_PROFILE` |
| 📦 Product Analytics | `PRODUCT_KPI`, `PRODUCT_OVERVIEW`, `AI_REVIEW_SENTIMENT` |
| 💰 Sales Analytics | `SALES_OVERVIEW`, `RETURNS_REFUNDS_OVERVIEW` |
| 🏬 Inventory Analytics | `INVENTORY_OVERVIEW`, `STOCK_ALERTS_OVERVIEW` |
| 📣 Marketing Analytics | `MARKETING_OVERVIEW`, `MARKETING_ATTRIBUTION_OVERVIEW`, `AI_CAMPAIGN_INSIGHTS` |
| 🧪 Data Quality | `DQ_OVERVIEW`, `DQ_DOMAIN_OVERVIEW`, `DQ_FAILURES_OVERVIEW` |
| 🔎 Enterprise Search | `ENTERPRISE_SEARCH` |
| 🤖 AI Copilot | `AI_COPILOT_CONTEXT` (+ `ENTERPRISE_SEARCH`) |

---

## 🏗️ Project structure

```
.
├── app.py                       # Entry point + st.navigation routing + sidebar
├── utils/
│   ├── config.py                # Env-driven config (no hard-coded secrets)
│   ├── snowflake_client.py      # Private-key auth, cached connection & queries
│   ├── openai_client.py         # OpenAI chat/stream/summaries + offline fallback
│   ├── data_provider.py         # Unified LIVE↔DEMO data access
│   ├── mock_data.py             # Realistic synthetic data for all 21 views
│   ├── frames.py                # Schema-agnostic dataframe profiling
│   └── formatting.py            # Number / delta formatting
├── components/
│   ├── theme.py                 # Design system: CSS, hero, sections, badges
│   ├── kpi.py                   # KPI cards + SVG sparklines
│   ├── charts.py                # Themed Plotly + smart_chart()
│   └── blocks.py                # Reusable page blocks (filters, tables, AI)
└── pages/
    ├── executive.py  customer.py  product.py  sales.py  inventory.py
    ├── marketing.py  data_quality.py  enterprise_search.py  copilot.py
```

> Routing uses `st.navigation`, which disables Streamlit's automatic `pages/`
> multipage behaviour — so `pages/` is imported as a normal package.

---

## ▶️ Quick start

```bash
python -m venv .venv
.venv\Scripts\activate            # Windows  (source .venv/bin/activate on *nix)
pip install -r requirements.txt
streamlit run app.py              # opens http://localhost:8501  (DEMO mode)
```

Go **LIVE** by adding credentials:

```bash
cp .env.example .env              # then fill in the values below
```

| Variable | Description |
|----------|-------------|
| `OPENAI_API_KEY` | enables AI Copilot & summaries |
| `OPENAI_MODEL` | optional, default `gpt-4o-mini` |
| `SNOWFLAKE_ACCOUNT` | e.g. `ab12345.eu-west-1` |
| `SNOWFLAKE_USER` | service / login user |
| `SNOWFLAKE_PRIVATE_KEY_PATH` | path to PKCS#8 private key (`.p8`) |
| `SNOWFLAKE_PRIVATE_KEY_PASSPHRASE` | optional, if key is encrypted |
| `SNOWFLAKE_ROLE` / `SNOWFLAKE_WAREHOUSE` | role & warehouse |
| `SNOWFLAKE_DATABASE` / `SNOWFLAKE_SCHEMA` | `ANALYTICS_DB` / `PRESENTATION` |

### Generate a Snowflake key pair

```bash
openssl genrsa 2048 | openssl pkcs8 -topk8 -inform PEM -out rsa_key.p8 -nocrypt
openssl rsa -in rsa_key.p8 -pubout -out rsa_key.pub
```
```sql
ALTER USER my_user SET RSA_PUBLIC_KEY='<base64 body of rsa_key.pub>';
```

---

## 🤖 How the AI Copilot works

1. **Retrieve** supporting rows from `ANALYTICS_DB.PRESENTATION.AI_COPILOT_CONTEXT`
   (falling back to `ENTERPRISE_SEARCH`).
2. **Ground** an OpenAI chat completion on those rows — with strict instructions
   to cite real numbers and never fabricate.
3. **Stream** the answer ChatGPT-style.
4. **Show the evidence** — a collapsible panel with the underlying table and an
   auto-selected chart.

No OpenAI key? The Copilot still answers, composing a grounded response from the
retrieved context.

---

## 🛡️ Security

- Secrets come only from environment variables; `.env` and `*.p8` are git-ignored.
- Snowflake uses **key-pair authentication** (no passwords in the app).
- The app reads only from the curated `ANALYTICS_DB.PRESENTATION` layer.
- Search queries use parameterised bind variables.

---

*Built as a portfolio-grade enterprise analytics + GenAI reference application.*
