import json
from graphviz import Digraph

MANIFEST_PATH = "target/manifest.json"
OUTPUT_FILE = "dbt_lineage"

with open(MANIFEST_PATH, "r", encoding="utf-8") as f:
    manifest = json.load(f)

nodes = manifest.get("nodes", {})
sources = manifest.get("sources", {})

dot = Digraph("dbt_lineage", format="png")
dot.attr(rankdir="LR")
dot.attr("node", shape="box", style="rounded,filled", fontname="Arial", fontsize="10")
dot.attr("edge", color="#6B7280")

def node_label(unique_id, obj):
    return obj.get("name", unique_id.split(".")[-1])

def node_color(unique_id):
    name = unique_id.lower()
    if unique_id.startswith("source."):
        return "#14B8A6"
    if ".bronze." in name or "bronze" in name:
        return "#38BDF8"
    if ".silver." in name or "silver" in name:
        return "#60A5FA"
    if ".gold." in name or "gold" in name or "mart" in name:
        return "#A78BFA"
    if "dim_" in name:
        return "#22C55E"
    if "fct_" in name or "fact" in name:
        return "#F97316"
    if "analytics" in name:
        return "#EC4899"
    if "dq" in name:
        return "#FACC15"
    if "ai" in name:
        return "#FB7185"
    return "#E5E7EB"

all_objects = {}
all_objects.update(nodes)
all_objects.update(sources)

for unique_id, obj in all_objects.items():
    if unique_id.startswith(("model.", "source.")):
        dot.node(
            unique_id,
            label=node_label(unique_id, obj),
            fillcolor=node_color(unique_id),
            color="#111827",
            fontcolor="#111827"
        )

for unique_id, obj in nodes.items():
    if not unique_id.startswith("model."):
        continue

    depends_on = obj.get("depends_on", {}).get("nodes", [])

    for parent_id in depends_on:
        if parent_id in all_objects:
            dot.edge(parent_id, unique_id)

dot.render(OUTPUT_FILE, cleanup=True)

print(f"Lineage image created: {OUTPUT_FILE}.png")