"""Number / value formatting helpers used across the UI."""
from __future__ import annotations

import math
from numbers import Number


def is_nan(v) -> bool:
    return isinstance(v, float) and math.isnan(v)


def compact(value) -> str:
    """Human-friendly compact number (1.2K, 3.4M, 5.6B)."""
    if value is None or is_nan(value):
        return "—"
    if not isinstance(value, Number):
        return str(value)
    v = float(value)
    a = abs(v)
    if a >= 1_000_000_000:
        return f"{v/1e9:.2f}B"
    if a >= 1_000_000:
        return f"{v/1e6:.2f}M"
    if a >= 1_000:
        return f"{v/1e3:.1f}K"
    if a and a < 1:
        return f"{v:.2f}"
    return f"{v:,.0f}" if float(v).is_integer() else f"{v:,.2f}"


def currency(value, symbol: str = "$") -> str:
    if value is None or is_nan(value) or not isinstance(value, Number):
        return "—"
    return f"{symbol}{compact(value)}"


def percent(value, digits: int = 1) -> str:
    if value is None or is_nan(value) or not isinstance(value, Number):
        return "—"
    v = float(value)
    # values < 1 treated as fractions
    return f"{v*100:.{digits}f}%" if abs(v) <= 1 else f"{v:.{digits}f}%"


def delta_parts(delta) -> tuple[str, str]:
    """Return (text, direction) where direction ∈ {up, down, flat}."""
    if delta is None or is_nan(delta) or not isinstance(delta, Number):
        return "", "flat"
    d = float(delta)
    direction = "up" if d > 0 else ("down" if d < 0 else "flat")
    arrow = "▲" if d > 0 else ("▼" if d < 0 else "▬")
    text = f"{arrow} {abs(d)*100:.1f}%" if abs(d) <= 1 else f"{arrow} {abs(d):,.1f}"
    return text, direction
