"""
Realistic synthetic data for every presentation view.

Used automatically when Snowflake credentials are not configured, so the app is
fully interactive and portfolio-ready out of the box. All generators are seeded
and internally consistent (e.g. revenue trend ≈ sum of channel sales).
"""
from __future__ import annotations

import numpy as np
import pandas as pd

SEED = 7
COUNTRIES = ["United States", "United Kingdom", "Germany", "France", "Canada",
             "Australia", "Japan", "Brazil", "India", "Netherlands"]
CATEGORIES = ["Electronics", "Apparel", "Home & Kitchen", "Beauty", "Sports",
              "Toys", "Grocery", "Automotive"]
CHANNELS = ["Paid Search", "Social", "Email", "Organic", "Affiliate", "Display"]
SEGMENTS = ["Champions", "Loyal", "Potential", "New", "At Risk", "Hibernating"]
WAREHOUSES = ["DC-East", "DC-West", "DC-Central", "DC-North", "EU-Hub", "APAC-Hub"]
DOMAINS = ["Sales", "Customer", "Product", "Inventory", "Marketing", "Finance"]
PRODUCTS = [
    "Aurora Wireless Earbuds", "Nimbus Smart Speaker", "Vertex 4K Monitor",
    "Pulse Fitness Band", "Cirrus Air Purifier", "Lumen Desk Lamp",
    "Terra Cast-Iron Skillet", "Zephyr Hair Dryer", "Atlas Backpack Pro",
    "Cobalt Mechanical Keyboard", "Solace Weighted Blanket", "Drift Running Shoes",
    "Orbit Robot Vacuum", "Ember Travel Mug", "Sage Yoga Mat",
]


def _rng() -> np.random.Generator:
    return np.random.default_rng(SEED)


# ── KPI views (long format: METRIC / VALUE / DELTA) ─────────────────────────
def _executive_kpi() -> pd.DataFrame:
    return pd.DataFrame([
        ("Total Revenue", 48_920_000, 0.142),
        ("Orders", 312_540, 0.083),
        ("Avg Order Value", 156.52, 0.054),
        ("Active Customers", 184_300, 0.111),
        ("Gross Margin", 0.412, 0.018),
        ("Return Rate", 0.067, -0.009),
        ("Conversion Rate", 0.034, 0.006),
        ("NPS", 62, 0.04),
    ], columns=["METRIC", "VALUE", "DELTA"])


def _customer_kpi() -> pd.DataFrame:
    return pd.DataFrame([
        ("Active Customers", 184_300, 0.111),
        ("New Customers", 21_450, 0.176),
        ("Avg Customer LTV", 1_284.0, 0.061),
        ("Churn Rate", 0.052, -0.012),
        ("Repeat Purchase Rate", 0.387, 0.022),
        ("Avg Orders / Customer", 3.4, 0.05),
    ], columns=["METRIC", "VALUE", "DELTA"])


def _product_kpi() -> pd.DataFrame:
    return pd.DataFrame([
        ("Active SKUs", 4_820, 0.03),
        ("Avg Margin", 0.41, 0.014),
        ("Top Category Share", 0.286, 0.008),
        ("Avg Rating", 4.3, 0.02),
        ("Out-of-Stock SKUs", 137, -0.06),
        ("New Launches", 64, 0.21),
    ], columns=["METRIC", "VALUE", "DELTA"])


def _dq_overview() -> pd.DataFrame:
    return pd.DataFrame([
        ("Overall Quality Score", 0.964, 0.011),
        ("Completeness", 0.981, 0.004),
        ("Validity", 0.957, 0.009),
        ("Uniqueness", 0.992, 0.001),
        ("Timeliness", 0.948, 0.017),
        ("Failed Checks (24h)", 23, -0.18),
    ], columns=["METRIC", "VALUE", "DELTA"])


# ── Trend / breakdown views ─────────────────────────────────────────────────
def _revenue_trend() -> pd.DataFrame:
    rng = _rng()
    months = pd.date_range(end=pd.Timestamp.today().normalize().replace(day=1),
                           periods=24, freq="MS")
    base = np.linspace(1.4, 2.3, 24)
    seasonal = 1 + 0.18 * np.sin(np.linspace(0, 4 * np.pi, 24))
    noise = rng.normal(1, 0.05, 24)
    revenue = (base * seasonal * noise) * 1_000_000
    orders = (revenue / rng.normal(156, 6, 24)).astype(int)
    return pd.DataFrame({
        "DATE": months,
        "REVENUE": revenue.round(0),
        "ORDERS": orders,
        "GROSS_MARGIN": (0.40 + rng.normal(0, 0.01, 24)).round(3),
    })


def _sales_country_category() -> pd.DataFrame:
    rng = _rng()
    rows = []
    for c in COUNTRIES:
        cw = rng.uniform(0.4, 1.6)
        for cat in CATEGORIES:
            rev = rng.uniform(120_000, 900_000) * cw
            rows.append((c, cat, round(rev), int(rev / rng.uniform(120, 200)),
                         int(rev / rng.uniform(40, 90))))
    return pd.DataFrame(rows, columns=["COUNTRY", "CATEGORY", "REVENUE", "ORDERS", "UNITS"])


def _customer_overview() -> pd.DataFrame:
    rng = _rng()
    rows = []
    weights = [0.16, 0.24, 0.18, 0.14, 0.16, 0.12]
    for seg, w in zip(SEGMENTS, weights):
        customers = int(184_300 * w)
        clv = rng.uniform(400, 2600)
        rows.append((seg, customers, round(customers * clv), round(clv, 0),
                     round(rng.uniform(0.02, 0.18), 3), round(rng.uniform(2, 6), 1)))
    return pd.DataFrame(rows, columns=["SEGMENT", "CUSTOMERS", "REVENUE",
                                       "AVG_CLV", "CHURN_RATE", "AVG_ORDERS"])


def _product_overview() -> pd.DataFrame:
    rng = _rng()
    rows = []
    for p in PRODUCTS:
        cat = rng.choice(CATEGORIES)
        units = int(rng.uniform(2_000, 40_000))
        price = rng.uniform(25, 320)
        rows.append((p, cat, round(units * price), units, round(rng.uniform(0.18, 0.62), 3),
                     round(rng.uniform(3.4, 4.9), 1)))
    df = pd.DataFrame(rows, columns=["PRODUCT", "CATEGORY", "REVENUE", "UNITS_SOLD",
                                     "MARGIN_PCT", "AVG_RATING"])
    return df.sort_values("REVENUE", ascending=False).reset_index(drop=True)


def _sales_overview() -> pd.DataFrame:
    rng = _rng()
    days = pd.date_range(end=pd.Timestamp.today().normalize(), periods=90, freq="D")
    rows = []
    for d in days:
        for ch in CHANNELS:
            rev = rng.uniform(8_000, 70_000)
            rows.append((d, ch, round(rev), int(rev / rng.uniform(120, 200)),
                         int(rev / rng.uniform(40, 90))))
    return pd.DataFrame(rows, columns=["DATE", "CHANNEL", "REVENUE", "ORDERS", "UNITS"])


def _returns_refunds() -> pd.DataFrame:
    rng = _rng()
    rows = []
    for cat in CATEGORIES:
        returns = int(rng.uniform(400, 4_000))
        rows.append((cat, returns, round(returns * rng.uniform(40, 130)),
                     round(rng.uniform(0.03, 0.12), 3)))
    return pd.DataFrame(rows, columns=["CATEGORY", "RETURNS", "REFUND_AMOUNT", "RETURN_RATE"])


def _inventory_overview() -> pd.DataFrame:
    rng = _rng()
    rows = []
    for wh in WAREHOUSES:
        for cat in CATEGORIES:
            units = int(rng.uniform(1_000, 30_000))
            rows.append((wh, cat, units, round(units * rng.uniform(8, 45)),
                         round(rng.uniform(8, 70), 1)))
    return pd.DataFrame(rows, columns=["WAREHOUSE", "CATEGORY", "STOCK_UNITS",
                                       "STOCK_VALUE", "DAYS_OF_SUPPLY"])


def _stock_alerts() -> pd.DataFrame:
    rng = _rng()
    rows = []
    statuses = ["Critical", "Low", "Reorder", "Overstock"]
    for _ in range(28):
        prod = rng.choice(PRODUCTS)
        wh = rng.choice(WAREHOUSES)
        reorder = int(rng.uniform(500, 3_000))
        stock = int(reorder * rng.uniform(0.05, 1.4))
        status = ("Critical" if stock < reorder * 0.25 else
                  "Low" if stock < reorder * 0.6 else
                  "Reorder" if stock < reorder else "Overstock")
        sev = {"Critical": 4, "Low": 3, "Reorder": 2, "Overstock": 1}[status]
        rows.append((prod, wh, stock, reorder, status, sev))
    df = pd.DataFrame(rows, columns=["PRODUCT", "WAREHOUSE", "STOCK_UNITS",
                                     "REORDER_POINT", "STATUS", "SEVERITY"])
    return df.sort_values("SEVERITY", ascending=False).reset_index(drop=True)


def _marketing_overview() -> pd.DataFrame:
    rng = _rng()
    rows = []
    for ch in CHANNELS:
        spend = rng.uniform(60_000, 480_000)
        impressions = int(spend * rng.uniform(20, 60))
        clicks = int(impressions * rng.uniform(0.01, 0.05))
        conv = int(clicks * rng.uniform(0.02, 0.09))
        revenue = conv * rng.uniform(90, 220)
        rows.append((ch, round(spend), impressions, clicks, conv,
                     round(revenue), round(revenue / spend, 2)))
    return pd.DataFrame(rows, columns=["CHANNEL", "SPEND", "IMPRESSIONS", "CLICKS",
                                       "CONVERSIONS", "REVENUE", "ROAS"])


def _marketing_attribution() -> pd.DataFrame:
    rng = _rng()
    rows = []
    for ch in CHANNELS:
        rows.append((ch, round(rng.uniform(200_000, 1_400_000)),
                     int(rng.uniform(1_500, 12_000)), int(rng.uniform(2, 6)),
                     round(rng.uniform(0.08, 0.32), 3)))
    return pd.DataFrame(rows, columns=["CHANNEL", "ATTRIBUTED_REVENUE", "CONVERSIONS",
                                       "AVG_TOUCHPOINTS", "ATTRIBUTION_SHARE"])


def _dq_domain() -> pd.DataFrame:
    rng = _rng()
    rows = []
    for d in DOMAINS:
        records = int(rng.uniform(500_000, 5_000_000))
        score = round(rng.uniform(0.90, 0.99), 3)
        rows.append((d, score, records, int(records * (1 - score) * rng.uniform(0.2, 0.8))))
    return pd.DataFrame(rows, columns=["DOMAIN", "QUALITY_SCORE", "RECORDS", "FAILURES"])


def _dq_failures() -> pd.DataFrame:
    rng = _rng()
    checks = [
        ("not_null:customer_email", "Customer", "Email must not be null"),
        ("unique:order_id", "Sales", "Order id must be unique"),
        ("range:discount_pct", "Sales", "Discount between 0 and 1"),
        ("fk:product_id", "Product", "Product id must exist in dim_product"),
        ("freshness:inventory_snapshot", "Inventory", "Snapshot < 24h old"),
        ("accepted_values:channel", "Marketing", "Channel in allowed set"),
        ("not_null:ship_country", "Sales", "Ship country required"),
        ("positive:stock_units", "Inventory", "Stock units >= 0"),
    ]
    sev = ["Critical", "High", "Medium", "Low"]
    rows = []
    for name, domain, rule in checks:
        rows.append((name, domain, rng.choice(sev, p=[0.15, 0.3, 0.35, 0.2]),
                     int(rng.uniform(1, 900)), rule))
    return pd.DataFrame(rows, columns=["CHECK_NAME", "DOMAIN", "SEVERITY",
                                       "FAILED_RECORDS", "RULE"])


# ── AI views (with text columns) ────────────────────────────────────────────
def _ai_review_sentiment() -> pd.DataFrame:
    rng = _rng()
    rows = []
    for p in PRODUCTS:
        reviews = int(rng.uniform(120, 3_200))
        pos = round(rng.uniform(0.55, 0.95), 3)
        rows.append((p, reviews, round(rng.uniform(3.3, 4.9), 1), pos,
                     round(rng.uniform(0.02, 0.2), 3),
                     "Praised for value and build quality" if pos > 0.8
                     else "Mixed feedback on durability"))
    return pd.DataFrame(rows, columns=["PRODUCT", "REVIEWS", "AVG_RATING",
                                       "POSITIVE_PCT", "NEGATIVE_PCT", "SUMMARY"])


def _ai_customer_profile() -> pd.DataFrame:
    profiles = {
        "Champions": ("High-frequency, high-value buyers with strong brand loyalty.",
                      "Reward with early access & referrals."),
        "Loyal": ("Consistent repeat buyers responsive to loyalty perks.",
                  "Upsell premium tiers and bundles."),
        "Potential": ("Recent buyers showing rising engagement.",
                      "Nurture with personalised recommendations."),
        "New": ("First-time buyers still forming an opinion.",
                "Onboard with welcome series and education."),
        "At Risk": ("Previously active, now declining engagement.",
                    "Win back with targeted offers."),
        "Hibernating": ("Long-dormant customers, low recent activity.",
                        "Re-engage or suppress to protect deliverability."),
    }
    rng = _rng()
    rows = []
    for seg, (profile, action) in profiles.items():
        rows.append((seg, int(184_300 * rng.uniform(0.1, 0.25)),
                     round(rng.uniform(400, 2600), 0), profile, action))
    return pd.DataFrame(rows, columns=["SEGMENT", "CUSTOMERS", "AVG_CLV",
                                       "PROFILE", "RECOMMENDED_ACTION"])


def _ai_campaign_insights() -> pd.DataFrame:
    rng = _rng()
    data = [
        ("Spring Launch", "Paid Search", "ROAS 18% above target driven by branded keywords.",
         "Shift 10% budget from Display to Paid Search."),
        ("Loyalty Boost", "Email", "Open rates up but conversion lagging on mobile.",
         "A/B test mobile checkout and shorter CTAs."),
        ("Influencer Q3", "Social", "Strong reach, weak attributed revenue.",
         "Add discount codes per creator to track impact."),
        ("Retargeting", "Display", "High frequency causing ad fatigue.",
         "Cap frequency at 4/week and refresh creative."),
        ("Back-to-School", "Affiliate", "Top affiliates drive 60% of conversions.",
         "Negotiate exclusive rates with top 5 partners."),
    ]
    rows = [(c, ch, ins, rec, round(rng.uniform(0.05, 0.3), 3))
            for c, ch, ins, rec in data]
    return pd.DataFrame(rows, columns=["CAMPAIGN", "CHANNEL", "INSIGHT",
                                       "RECOMMENDATION", "EST_IMPACT"])


def _enterprise_search() -> pd.DataFrame:
    rng = _rng()
    rows = []
    templates = [
        ("Customer", "Customer {} — {} segment", "Lifetime value ${}, last order {} days ago."),
        ("Product", "{} ({})", "Revenue ${}K, margin {}%, rating {}."),
        ("Campaign", "{} campaign on {}", "ROAS {}, attributed revenue ${}K."),
        ("Order", "Order #{}", "Total ${}, status {}, country {}."),
        ("Metric", "{} KPI", "Current value {}, trending {} vs last period."),
    ]
    for i in range(60):
        etype, title_t, content_t = templates[i % len(templates)]
        if etype == "Customer":
            title = title_t.format(f"C-{1000+i}", rng.choice(SEGMENTS))
            content = content_t.format(int(rng.uniform(200, 3000)), int(rng.uniform(1, 120)))
            domain = "Customer"
        elif etype == "Product":
            p = rng.choice(PRODUCTS)
            title = title_t.format(p, rng.choice(CATEGORIES))
            content = content_t.format(int(rng.uniform(50, 9000)), int(rng.uniform(18, 62)),
                                       round(rng.uniform(3.4, 4.9), 1))
            domain = "Product"
        elif etype == "Campaign":
            title = title_t.format(rng.choice(["Spring", "Summer", "Holiday", "Loyalty"]),
                                   rng.choice(CHANNELS))
            content = content_t.format(round(rng.uniform(1.5, 6), 1), int(rng.uniform(50, 1400)))
            domain = "Marketing"
        elif etype == "Order":
            title = title_t.format(100000 + i)
            content = content_t.format(int(rng.uniform(30, 900)),
                                       rng.choice(["Delivered", "Shipped", "Returned"]),
                                       rng.choice(COUNTRIES))
            domain = "Sales"
        else:
            title = title_t.format(rng.choice(["Revenue", "Churn", "AOV", "Conversion"]))
            content = content_t.format(round(rng.uniform(10, 5000), 1),
                                       rng.choice(["up", "down"]))
            domain = "Finance"
        rows.append((etype, title, content, domain,
                     pd.Timestamp.today().normalize() - pd.Timedelta(days=int(rng.uniform(0, 180))),
                     round(rng.uniform(0.6, 0.99), 3)))
    return pd.DataFrame(rows, columns=["ENTITY_TYPE", "TITLE", "CONTENT",
                                       "DOMAIN", "UPDATED_AT", "RELEVANCE"])


def _ai_copilot_context() -> pd.DataFrame:
    rows = [
        ("Revenue", "Total Revenue", "$48.9M", "Up 14.2% YoY; Electronics and Apparel lead growth.", "Sales"),
        ("Revenue", "Avg Order Value", "$156.52", "Up 5.4%; bundles and upsells improving basket size.", "Sales"),
        ("Customer", "Active Customers", "184.3K", "Up 11.1%; Champions and Loyal segments expanding.", "Customer"),
        ("Customer", "Churn Rate", "5.2%", "Down 1.2pts; win-back campaigns reducing at-risk churn.", "Customer"),
        ("Product", "Top Product", "Aurora Wireless Earbuds", "Highest revenue SKU; 4.7 rating, 38K units.", "Product"),
        ("Inventory", "Critical Alerts", "7 SKUs", "Below 25% of reorder point across DC-East and EU-Hub.", "Inventory"),
        ("Marketing", "Best Channel", "Paid Search", "Highest ROAS at 4.8x; branded keywords outperforming.", "Marketing"),
        ("Marketing", "Underperformer", "Display", "ROAS 1.6x; ad fatigue from high frequency.", "Marketing"),
        ("Quality", "Data Quality", "96.4%", "Healthy; 23 failed checks in last 24h, mostly Medium severity.", "Finance"),
        ("Returns", "Return Rate", "6.7%", "Down 0.9pts; Apparel remains highest-return category.", "Sales"),
    ]
    return pd.DataFrame(rows, columns=["TOPIC", "METRIC", "VALUE", "CONTEXT", "DOMAIN"])


_GENERATORS = {
    "EXECUTIVE_KPI": _executive_kpi,
    "CUSTOMER_KPI": _customer_kpi,
    "PRODUCT_KPI": _product_kpi,
    "DQ_OVERVIEW": _dq_overview,
    "REVENUE_TREND": _revenue_trend,
    "SALES_COUNTRY_CATEGORY": _sales_country_category,
    "CUSTOMER_OVERVIEW": _customer_overview,
    "PRODUCT_OVERVIEW": _product_overview,
    "SALES_OVERVIEW": _sales_overview,
    "RETURNS_REFUNDS_OVERVIEW": _returns_refunds,
    "INVENTORY_OVERVIEW": _inventory_overview,
    "STOCK_ALERTS_OVERVIEW": _stock_alerts,
    "MARKETING_OVERVIEW": _marketing_overview,
    "MARKETING_ATTRIBUTION_OVERVIEW": _marketing_attribution,
    "DQ_DOMAIN_OVERVIEW": _dq_domain,
    "DQ_FAILURES_OVERVIEW": _dq_failures,
    "AI_REVIEW_SENTIMENT": _ai_review_sentiment,
    "AI_CUSTOMER_PROFILE": _ai_customer_profile,
    "AI_CAMPAIGN_INSIGHTS": _ai_campaign_insights,
    "ENTERPRISE_SEARCH": _enterprise_search,
    "AI_COPILOT_CONTEXT": _ai_copilot_context,
}


def generate(view: str) -> pd.DataFrame:
    gen = _GENERATORS.get(view.upper())
    return gen() if gen else pd.DataFrame()
