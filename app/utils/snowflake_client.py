"""Snowflake connectivity via key-pair (private key) authentication."""
from __future__ import annotations

import os

import pandas as pd
import streamlit as st

from utils.config import SnowflakeConfig, fq, snowflake_config


def _load_private_key(cfg: SnowflakeConfig) -> bytes:
    from cryptography.hazmat.backends import default_backend
    from cryptography.hazmat.primitives import serialization

    if not cfg.private_key_path or not os.path.exists(cfg.private_key_path):
        raise FileNotFoundError(f"Private key not found: {cfg.private_key_path}")

    with open(cfg.private_key_path, "rb") as f:
        key = serialization.load_pem_private_key(
            f.read(),
            password=(cfg.private_key_passphrase.encode()
                      if cfg.private_key_passphrase else None),
            backend=default_backend(),
        )
    return key.private_bytes(
        encoding=serialization.Encoding.DER,
        format=serialization.PrivateFormat.PKCS8,
        encryption_algorithm=serialization.NoEncryption(),
    )


@st.cache_resource(show_spinner=False)
def get_connection():
    import snowflake.connector

    cfg = snowflake_config()
    return snowflake.connector.connect(
        account=cfg.account,
        user=cfg.user,
        private_key=_load_private_key(cfg),
        role=cfg.role or None,
        warehouse=cfg.warehouse or None,
        database=cfg.database,
        schema=cfg.schema,
        client_session_keep_alive=True,
        application="Cortex_Analytics",
    )


def test_connection() -> tuple[bool, str]:
    try:
        conn = get_connection()
        with conn.cursor() as cur:
            cur.execute("SELECT CURRENT_VERSION()")
            v = cur.fetchone()[0]
        return True, f"Snowflake {v}"
    except Exception as exc:  # noqa: BLE001
        return False, str(exc)


@st.cache_data(ttl=600, show_spinner=False)
def run_query(sql: str, params: tuple | None = None) -> pd.DataFrame:
    conn = get_connection()
    with conn.cursor() as cur:
        cur.execute(sql, params or None)
        try:
            df = cur.fetch_pandas_all()
        except Exception:  # noqa: BLE001 - non-arrow result
            rows = cur.fetchall()
            cols = [c[0] for c in cur.description]
            df = pd.DataFrame(rows, columns=cols)
    df.columns = [str(c) for c in df.columns]
    return df


def load_view(view: str, limit: int | None = None) -> pd.DataFrame:
    sql = f"SELECT * FROM {fq(view)}"
    if limit:
        sql += f" LIMIT {int(limit)}"
    return run_query(sql)


def view_columns(view: str) -> list[str]:
    return list(run_query(f"SELECT * FROM {fq(view)} LIMIT 0").columns)
