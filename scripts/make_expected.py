"""Writes expected.json from a coverage.json that was verified by hand.

usage: python scripts/make_expected.py coverage.json expected.json "description"
"""
import json, sys
rep = json.load(open(sys.argv[1], encoding='utf-8-sig'))
out = {"description": sys.argv[3] if len(sys.argv) > 3 else "", "methods": []}
for m in rep["methods"]:
    if not m["items"]:
        continue
    s = m["summary"]
    out["methods"].append({
        "name": m["name"],
        "branch": [s["branch"]["covered"], s["branch"]["total"]],
        "condition": [s["condition"]["covered"], s["condition"]["total"]],
        "combination": [s["combination"]["covered"], s["combination"]["total"]],
        "uncovered": [f'L{i["line"]} {i["kind"]} {i["label"]}' for i in m["items"] if not i["covered"]],
    })
json.dump(out, open(sys.argv[2], "w", encoding="utf-8"), ensure_ascii=False, indent=1)
print("wrote", sys.argv[2], len(out["methods"]), "methods")
